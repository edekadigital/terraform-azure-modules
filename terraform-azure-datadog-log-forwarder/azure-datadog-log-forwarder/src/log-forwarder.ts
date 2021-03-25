// Unless explicitly stated otherwise all files in this repository are licensed
// under the Apache License Version 2.0.
// This product includes software developed at Datadog (https://www.datadoghq.com/).
// Copyright 2020 Datadog, Inc.

import {Context} from '@azure/functions';
import {URL} from 'node:url';
import {RequestOptions} from 'https';

const https = require('https');

const STRING = 'string'; // example: 'some message'
const STRING_ARRAY = 'string-array'; // example: ['one message', 'two message', ...]
const JSON_OBJECT = 'json-object'; // example: {"key": "value"}
const JSON_ARRAY = 'json-array'; // example: [{"key": "value"}, {"key": "value"}, ...] or [{"records": [{}, {}, ...]}, {"records": [{}, {}, ...]}, ...]
const BUFFER_ARRAY = 'buffer-array'; // example: [<Buffer obj>, <Buffer obj>]
const JSON_STRING = 'json-string'; // example: '{"key": "value"}'
const JSON_STRING_ARRAY = 'json-string-array'; // example: ['{"records": [{}, {}]}'] or ['{"key": "value"}']
const INVALID = 'invalid';

const JSON_TYPE = 'json';
const STRING_TYPE = 'string';

const DD_API_KEY = process.env.DD_API_KEY || '<DATADOG_API_KEY>';
const DD_SITE = process.env.DD_SITE || 'datadoghq.com';
const DD_URL = process.env.DD_URL || 'http-intake.logs.' + DD_SITE;
const DD_PORT = process.env.DD_PORT || 443;
const DD_TAGS = process.env.DD_TAGS || ''; // Replace '' by your comma-separated list of tags
const DD_SERVICE = process.env.DD_SERVICE || 'azure';
const DD_SOURCE = process.env.DD_SOURCE || 'azure';
const DD_SOURCE_CATEGORY = process.env.DD_SOURCE_CATEGORY || 'azure';

export interface Rule {
  pattern: string;
  replacement: string;
}

export interface Config {
  name: string;
  rule: Rule;
}

export interface RecordMessage {
  resourceId: string;
}

export interface Metadata {
  tags: string[];
  source: string;
}

class ScrubberRule {
  name: string;
  regexp: RegExp;
  replacement: string;

  constructor(name: string, pattern: string, replacement: string) {
    this.name = name;
    this.replacement = replacement;
    this.regexp = RegExp(pattern, 'g');
  }
}

class Scrubber {
  rules: ScrubberRule[] = [];

  constructor(context: Context, configs: Config[]) {
    configs.forEach(config => {
      try {
        this.rules.push(
          new ScrubberRule(
            config.name,
            config.rule.pattern,
            config.rule.replacement
          )
        );
      } catch {
        context.log.error(
          `Regexp for rule ${config.name} pattern ${config.rule.pattern} is malformed, skipping. Please update the pattern for this rule to be applied.`
        );
      }
    });
  }

  scrub(record: string) {
    if (!this.rules) {
      return record;
    }
    this.rules.forEach(rule => {
      record = record.replace(rule.regexp, rule.replacement);
    });
    return record;
  }
}

class EventhubLogForwarder {
  scrubber: Scrubber;
  context: Context;
  options: RequestOptions | string | URL;

  /*
To scrub PII from your logs, uncomment the applicable configs below. If you'd like to scrub more than just
emails and IP addresses, add your own config to this map in the format
NAME: {pattern: <regex_pattern>, replacement: <string to replace matching text with>}
*/
  SCRUBBER_RULE_CONFIGS: Config[] = [];

  constructor(context: Context) {
    this.context = context;
    this.options = {
      hostname: DD_URL,
      port: DD_PORT,
      path: '/v1/input',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'DD-API-KEY': DD_API_KEY,
      },
      timeout: 2000,
    };
    this.scrubber = new Scrubber(this.context, this.SCRUBBER_RULE_CONFIGS);
  }

  async formatLogAndSend(messageType: string, record: any) {
    if (messageType == JSON_TYPE) {
      record = this.addTagsToJsonLog(record);
    } else {
      record = this.addTagsToStringLog(record);
    }
    return await this.sendWithRetry(record);
  }

  async sendWithRetry(record: any): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      return this.send(record)
        .then(res => {
          resolve();
        })
        .catch(err => {
          setTimeout(() => {
            this.send(record)
              .then(res => {
                resolve();
              })
              .catch(err => {
                this.context.log.error(
                  `unable to send request after 2 tries, err: ${err}`
                );
                reject();
              });
          }, 1000);
        });
    });
  }

  async send(record: any): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      const req = https
        .request(this.options, (resp: {statusCode: number}) => {
          if (resp.statusCode < 200 || resp.statusCode > 299) {
            reject(`invalid status code ${resp.statusCode}`);
          } else {
            resolve();
          }
        })
        .on('error', (error: any) => {
          reject(error);
        });
      req.write(this.scrubber.scrub(JSON.stringify(record)));
      req.end();
    });
  }

  async handleLogs(logs: any) {
    let promises: Promise<void>[] = [];
    const logsType = this.getLogFormat(logs);
    switch (logsType) {
      case STRING:
        promises.push(this.formatLogAndSend(STRING_TYPE, logs));
        break;
      case JSON_STRING:
        logs = JSON.parse(logs as string);
        promises.push(this.formatLogAndSend(JSON_TYPE, logs));
        break;
      case JSON_OBJECT:
        promises.push(this.formatLogAndSend(JSON_TYPE, logs));
        break;
      case STRING_ARRAY:
        logs.forEach((log: string) =>
          promises.push(this.formatLogAndSend(STRING_TYPE, log))
        );
        break;
      case JSON_ARRAY:
        promises = await this.handleJSONArrayLogs(logs, JSON_ARRAY);
        break;
      case BUFFER_ARRAY:
        await this.handleJSONArrayLogs(logs, BUFFER_ARRAY);
        break;
      case JSON_STRING_ARRAY:
        promises = await this.handleJSONArrayLogs(logs, JSON_STRING_ARRAY);
        break;
      case INVALID:
      default:
        this.context.log.warn('logs format is invalid');
        break;
    }
    return promises;
  }

  async handleJSONArrayLogs(logs: any, logsType: string) {
    let promises: Promise<void>[] = [];
    logs.forEach((message: any) => {
      if (logsType == JSON_STRING_ARRAY) {
        try {
          message = JSON.parse(message as string);
        } catch (err) {
          this.context.log.warn('log is malformed json, sending as string');
          promises.push(this.formatLogAndSend(STRING_TYPE, message));
          return;
        }
      }
      // If the message is a buffer object, the data type has been set to binary.
      if (logsType == BUFFER_ARRAY) {
        try {
          message = JSON.parse(message.toString());
        } catch (err) {
          this.context.log.warn('log is malformed json, sending as string');
          promises.push(this.formatLogAndSend(STRING_TYPE, message.toString()));
          return;
        }
      }
      if (message.records != undefined) {
        message.records.forEach((message: any) =>
          promises.push(this.formatLogAndSend(JSON_TYPE, message))
        );
      } else {
        this.formatLogAndSend(JSON_TYPE, message);
      }
    });
    return promises;
  }

  getLogFormat(logs: any): string {
    if (typeof logs === 'string') {
      if (this.isJsonString(logs)) {
        return JSON_STRING;
      }
      return STRING;
    }
    if (!Array.isArray(logs) && typeof logs === 'object' && logs !== null) {
      return JSON_OBJECT;
    }
    if (!Array.isArray(logs)) {
      return INVALID;
    }
    if (Buffer.isBuffer(logs[0])) {
      return BUFFER_ARRAY;
    }
    if (typeof logs[0] === 'object') {
      return JSON_ARRAY;
    }
    if (typeof logs[0] === 'string') {
      if (this.isJsonString(logs[0])) {
        return JSON_STRING_ARRAY;
      } else {
        return STRING_ARRAY;
      }
    }
    return INVALID;
  }

  isJsonString(record: string): boolean {
    try {
      JSON.parse(record);
      return true;
    } catch (err) {
      return false;
    }
  }

  addTagsToJsonLog(record: any): any {
    const metadata = this.extractMetadataFromResource(record);
    record['ddsource'] = metadata.source || DD_SOURCE;
    record['ddsourcecategory'] = DD_SOURCE_CATEGORY;
    record['service'] = DD_SERVICE;
    record['ddtags'] = metadata.tags
      .concat([
        DD_TAGS,
        'forwardername:' + this.context.executionContext.functionName,
      ])
      .filter(Boolean)
      .join(',');
    return record;
  }

  addTagsToStringLog(stringLog: string): any {
    const jsonLog = {message: stringLog};
    return this.addTagsToJsonLog(jsonLog);
  }

  createResourceIdArray(record: RecordMessage): string[] {
    // Convert the resource ID in the record to an array, handling beginning/ending slashes
    let resourceId = record.resourceId.toLowerCase().split('/');
    if (resourceId[0] === '') {
      resourceId = resourceId.slice(1);
    }
    if (resourceId[resourceId.length - 1] === '') {
      resourceId.pop();
    }
    return resourceId;
  }

  isSource(resourceIdPart: string): boolean {
    // Determine if a section of a resource ID counts as a "source," in our case it means it starts with 'microsoft.'
    return resourceIdPart.startsWith('microsoft.');
  }

  formatSourceType(sourceType: string): string {
    return sourceType.replace('microsoft.', 'azure.');
  }

  extractMetadataFromResource(record: any): Metadata {
    let metadata: Metadata = {
      source: '',
      tags: [],
    };
    if (
      record.resourceId === undefined ||
      typeof record.resourceId !== 'string'
    ) {
      return metadata;
    }

    const resourceId = this.createResourceIdArray(record);

    if (resourceId[0] === 'subscriptions') {
      if (resourceId.length > 1) {
        metadata.tags.push('subscription_id:' + resourceId[1]);
        if (resourceId.length == 2) {
          metadata.source = 'azure.subscription';
          return metadata;
        }
      }
      if (resourceId.length > 3) {
        if (resourceId[2] === 'providers' && this.isSource(resourceId[3])) {
          // handle provider-only resource IDs
          metadata.source = this.formatSourceType(resourceId[3]);
        } else {
          metadata.tags.push('resource_group:' + resourceId[3]);
          if (resourceId.length == 4) {
            metadata.source = 'azure.resourcegroup';
            return metadata;
          }
        }
      }
      if (resourceId.length > 5 && this.isSource(resourceId[5])) {
        metadata.source = this.formatSourceType(resourceId[5]);
      }
    } else if (resourceId[0] === 'tenants') {
      if (resourceId.length > 3 && resourceId[3]) {
        metadata.tags.push('tenant:' + resourceId[1]);
        metadata.source = this.formatSourceType(resourceId[3]).replace(
          'aadiam',
          'activedirectory'
        );
      }
    }
    return metadata;
  }
}

module.exports = async function (context: Context, eventHubMessages: any) {
  if (!DD_API_KEY || DD_API_KEY === '<DATADOG_API_KEY>') {
    const errorMessage =
      'You must configure your API key before starting this function (see ## Parameters section)';
    context.log.error(errorMessage);
    return;
  }

  const logForwarder = new EventhubLogForwarder(context);
  try {
    await logForwarder.handleLogs(eventHubMessages);
  } catch (e) {
    context.log.error(e);
  }
};

module.exports.forTests = {
  EventhubLogForwarder,
  Scrubber,
  ScrubberRule,
  constants: {
    STRING,
    STRING_ARRAY,
    JSON_OBJECT,
    JSON_ARRAY,
    BUFFER_ARRAY,
    JSON_STRING,
    JSON_STRING_ARRAY,
    INVALID,
  },
};
