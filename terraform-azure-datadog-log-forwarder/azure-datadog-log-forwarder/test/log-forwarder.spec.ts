import {Config, Rule} from '../src/log-forwarder';

const OLD_ENV = process.env;
const logForwarder = require('../src/log-forwarder');

describe('log-forwarder', () => {
  beforeEach(async () => {
    jest.resetModules(); // Most important - it clears the cache
    process.env = {...OLD_ENV}; // Make a copy
  });

  afterAll(async () => {
    process.env = OLD_ENV; // Restore old environment
  });

  it('should log error if DD_API_KEY is not set', async () => {
    // given
    const contextMock = jest.fn(() => {
      return {
        log: {
          error: (str: any) => {
            expect(str).toBe(
              'You must configure your API key before starting this function (see ## Parameters section)'
            );
          },
        },
      };
    });

    // when / then
    const eventHubMessages = {};
    await logForwarder(contextMock(), eventHubMessages);
  });

  it('should process empty eventHubMessages', async () => {
    // given
    process.env = Object.assign(process.env, {DD_API_KEY: 'value'});
    const contextMock = jest.fn(() => {
      return {
        log: {
          error: (str: any) => {
            expect(str).toBe(
              'You must configure your API key before starting this function (see ## Parameters section)'
            );
          },
        },
        executionContext: {
          functionName: 'blah',
        },
      };
    });
    // when / then
    const eventHubMessages = {};
    await logForwarder(contextMock(), eventHubMessages);
  });

  it('isSource: should return true', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    // when
    const actual = forwarder.isSource('microsoft.');
    // then
    expect(actual).toBeTruthy();
  });

  it('isSource: should return false', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    // when
    const actual = forwarder.isSource('not_microsoft.');
    // then
    expect(actual).not.toBeTruthy();
  });

  it('formatSourceType: should change microsoft to azure', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    // when
    const actual = forwarder.formatSourceType('microsoft.');
    // then
    expect(actual).toBe('azure.');
  });

  it('isJsonString: should return true', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const jsonLogInput =
      '{\n' +
      '    "records": [\n' +
      '        {\n' +
      '            "time": "2019-07-15T18:00:22.6235064Z",\n' +
      '            "resourceId": "/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/resourceGroups/crm-dev-rg/providers/Microsoft.Web/sites/crm-dev-cat-app",\n' +
      '            "category": "AppServiceAppLogs",\n' +
      '            "level": "Error",\n' +
      '            "operationName": "Microsoft.DummyProvider/dummyResourceType/dummySubType/dummyAction"\n' +
      '        },\n' +
      '        {\n' +
      '            "time": "2019-07-15T18:01:15.7532989Z",\n' +
      '            "resourceId": "/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/resourceGroups/crm-dev-rg/providers/Microsoft.Web/sites/crm-dev-cat-app",\n' +
      '            "category": "AppServiceAppLogs",\n' +
      '            "level": "Information",\n' +
      '            "operationName": "Microsoft.DummyProvider/dummyResourceType/dummySubType/dummyAction"\n' +
      '        }\n' +
      '    ]\n' +
      '}';
    // when
    const actual = forwarder.isJsonString(jsonLogInput);
    // then
    expect(actual).toBeTruthy();
  });

  it('isJsonString: should return false', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const notJsonLogInput = 'not json input';
    // when
    const actual = forwarder.isJsonString(notJsonLogInput);
    // then
    expect(actual).not.toBeTruthy();
  });

  it('createResourceIdArray: should parse resource id of even emitter', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const record = {
      resourceId:
        '/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/resourceGroups/crm-dev-rg/providers/Microsoft.Web/sites/crm-dev-cat-app',
    };
    // when
    const actual = forwarder.createResourceIdArray(record);
    // then
    expect(actual.length).toBe(8);

    expect(actual[0]).toBe('subscriptions');
    expect(actual[1]).toBe('f36e599d-8bf5-4f95-9740-a38a54eb6b98');
    expect(actual[2]).toBe('resourcegroups');
    expect(actual[3]).toBe('crm-dev-rg');
    expect(actual[4]).toBe('providers');
    expect(actual[5]).toBe('microsoft.web');
    expect(actual[6]).toBe('sites');
    expect(actual[7]).toBe('crm-dev-cat-app');
  });

  it('createResourceIdArray: should pop end path and parse resource id of even emitter', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const record = {
      resourceId:
        '/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/resourceGroups/crm-dev-rg/providers/Microsoft.Web/sites/crm-dev-cat-app/',
    };
    // when
    const actual = forwarder.createResourceIdArray(record);
    // then
    expect(actual.length).toBe(8);

    expect(actual[0]).toBe('subscriptions');
    expect(actual[1]).toBe('f36e599d-8bf5-4f95-9740-a38a54eb6b98');
    expect(actual[2]).toBe('resourcegroups');
    expect(actual[3]).toBe('crm-dev-rg');
    expect(actual[4]).toBe('providers');
    expect(actual[5]).toBe('microsoft.web');
    expect(actual[6]).toBe('sites');
    expect(actual[7]).toBe('crm-dev-cat-app');
  });

  it('getLogFormat: should return json-string', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const input = '{\n' + '   "key":"value"\n' + '}';
    // when
    const actual = forwarder.getLogFormat(input);
    // then
    expect(actual).toBe('json-string');
  });

  it('getLogFormat: should return string', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const input = 'string';
    // when
    const actual = forwarder.getLogFormat(input);
    // then
    expect(actual).toBe('string');
  });

  it('getLogFormat: should return json-object', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const input = {key: 'value'};
    // when
    const actual = forwarder.getLogFormat(input);
    // then
    expect(actual).toBe('json-object');
  });

  it('getLogFormat: should return buffer-array', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const input = [
      Buffer.from('bufStr1', 'utf8'),
      Buffer.from('bufStr2', 'utf8'),
    ];
    // when
    const actual = forwarder.getLogFormat(input);
    // then
    expect(actual).toBe('buffer-array');
  });

  it('getLogFormat: should return json-array', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const input = [{key: 'value'}, {key: 'value'}];
    // when
    const actual = forwarder.getLogFormat(input);
    // then
    expect(actual).toBe('json-array');
  });

  it('getLogFormat: should return json-string-array', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const input = ['{"key": "value"}', '{"key": "value"}'];
    // when
    const actual = forwarder.getLogFormat(input);
    // then
    expect(actual).toBe('json-string-array');
  });

  it('getLogFormat: should return string-array ', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const input = ['one message', 'two message'];
    // when
    const actual = forwarder.getLogFormat(input);
    // then
    expect(actual).toBe('string-array');
  });

  it('getLogFormat: should return invalid ', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const input = 1;
    // when
    const actual = forwarder.getLogFormat(input);
    // then
    expect(actual).toBe('invalid');
  });

  it('extractMetadataFromResource: should return metadata with empty tags and source because of undefined resourceId', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const input = {};
    // when
    const actual = forwarder.extractMetadataFromResource(input);
    // then
    expect(actual.tags.length).toBe(0);
    expect(actual.source).toBe('');
  });

  it('extractMetadataFromResource: should return metadata with empty tags and source because of resourceId is not a string', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const input = {resourceId: 1};
    // when
    const actual = forwarder.extractMetadataFromResource(input);
    // then
    expect(actual.tags.length).toBe(0);
    expect(actual.source).toBe('');
  });

  it('extractMetadataFromResource: resource id is of subscriptions type and source is web app -> should add proper tags and source', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const record = {
      resourceId:
        '/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/resourceGroups/crm-dev-rg/providers/Microsoft.Web/sites/crm-dev-cat-app',
    };
    // when
    const actual = forwarder.extractMetadataFromResource(record);
    // then
    expect(actual.tags.length).toBe(2);
    expect(actual.tags[0]).toBe(
      'subscription_id:f36e599d-8bf5-4f95-9740-a38a54eb6b98'
    );
    expect(actual.tags[1]).toBe('resource_group:crm-dev-rg');
    expect(actual.source).toBe('azure.web');
  });

  it('extractMetadataFromResource: source is direct the subscription -> should add proper tags and source', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const record = {
      resourceId: '/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98',
    };
    // when
    const actual = forwarder.extractMetadataFromResource(record);
    // then
    expect(actual.tags.length).toBe(1);
    expect(actual.tags[0]).toBe(
      'subscription_id:f36e599d-8bf5-4f95-9740-a38a54eb6b98'
    );
    expect(actual.source).toBe('azure.subscription');
  });

  it('extractMetadataFromResource: provider-only resource -> should add proper tags and source', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const record = {
      resourceId:
        '/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/providers/Microsoft.Web/sites/crm-dev-cat-app',
    };
    // when
    const actual = forwarder.extractMetadataFromResource(record);
    // then
    expect(actual.tags.length).toBe(1);
    expect(actual.tags[0]).toBe(
      'subscription_id:f36e599d-8bf5-4f95-9740-a38a54eb6b98'
    );
    expect(actual.source).toBe('azure.web');
  });

  it('extractMetadataFromResource: source is the resource group -> should add proper tags and source', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const record = {
      resourceId:
        '/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/resourceGroups/crm-dev-rg',
    };
    // when
    const actual = forwarder.extractMetadataFromResource(record);
    // then
    expect(actual.tags.length).toBe(2);
    expect(actual.tags[0]).toBe(
      'subscription_id:f36e599d-8bf5-4f95-9740-a38a54eb6b98'
    );
    expect(actual.tags[1]).toBe('resource_group:crm-dev-rg');
    expect(actual.source).toBe('azure.resourcegroup');
  });

  it('extractMetadataFromResource: resource is a Azure AD tenant -> should add proper tags and source', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const record = {
      resourceId:
        '/tenants/857a7b86-2d66-46f2-92e1-25be0c27e398/providers/Microsoft.aadiam',
    };
    // when
    const actual = forwarder.extractMetadataFromResource(record);
    // then
    expect(actual.tags.length).toBe(1);
    expect(actual.tags[0]).toBe('tenant:857a7b86-2d66-46f2-92e1-25be0c27e398');
    expect(actual.source).toBe('azure.activedirectory');
  });

  it('addTagsToJsonLog: should add proper additional tags', async () => {
    // given
    const context = {
      executionContext: {functionName: 'myFuncName'},
    };
    const forwarder = new logForwarder.forTests.EventhubLogForwarder(context);
    const record = {
      resourceId:
        '/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/resourceGroups/crm-dev-rg/providers/Microsoft.Web/sites/crm-dev-cat-app',
    };
    // when
    const actual = forwarder.addTagsToJsonLog(record);
    // then
    expect(actual).toMatchObject({
      resourceId:
        '/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/resourceGroups/crm-dev-rg/providers/Microsoft.Web/sites/crm-dev-cat-app',
      ddsource: 'azure.web',
      ddsourcecategory: 'azure',
      service: 'azure',
      ddtags:
        'subscription_id:f36e599d-8bf5-4f95-9740-a38a54eb6b98,resource_group:crm-dev-rg,forwardername:myFuncName',
    });
  });

  it('addTagsToStringLog: should add proper additional tags', async () => {
    // given
    const context = {
      executionContext: {functionName: 'myFuncName'},
    };
    const forwarder = new logForwarder.forTests.EventhubLogForwarder(context);
    const messageText = 'something happened';
    // when
    const actual = forwarder.addTagsToStringLog(messageText);
    // then
    expect(actual).toMatchObject({
      message: 'something happened',
      ddsource: 'azure',
      ddsourcecategory: 'azure',
      service: 'azure',
      ddtags: 'forwardername:myFuncName',
    });
  });

  it('formatLogAndSend: should send with retry for json type record', async () => {
    // given
    const context = {
      executionContext: {functionName: 'myFuncName'},
    };
    const forwarder = new logForwarder.forTests.EventhubLogForwarder(context);
    const record = {
      resourceId:
        '/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/providers/Microsoft.Web/sites/crm-dev-cat-app',
    };

    const sendWithRetrySpy = jest
      .spyOn(forwarder, 'sendWithRetry')
      .mockResolvedValue({});
    // when
    await forwarder.formatLogAndSend('json', record);
    // then
    expect(sendWithRetrySpy).toHaveBeenCalledTimes(1);
    expect(sendWithRetrySpy).toHaveBeenCalledWith({
      resourceId:
        '/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/providers/Microsoft.Web/sites/crm-dev-cat-app',
      ddsource: 'azure.web',
      ddsourcecategory: 'azure',
      service: 'azure',
      ddtags:
        'subscription_id:f36e599d-8bf5-4f95-9740-a38a54eb6b98,forwardername:myFuncName',
    });
  });

  it('formatLogAndSend: should send with retry for not json type record', async () => {
    // given
    const context = {
      executionContext: {functionName: 'myFuncName'},
    };
    const forwarder = new logForwarder.forTests.EventhubLogForwarder(context);
    const messageText = 'something happened';

    const sendWithRetrySpy = jest
      .spyOn(forwarder, 'sendWithRetry')
      .mockResolvedValue({});

    // when
    await forwarder.formatLogAndSend('string', messageText);

    // then
    expect(sendWithRetrySpy).toHaveBeenCalledTimes(1);
    expect(sendWithRetrySpy).toHaveBeenCalledWith({
      message: 'something happened',
      ddsource: 'azure',
      ddsourcecategory: 'azure',
      service: 'azure',
      ddtags: 'forwardername:myFuncName',
    });
  });

  it('handleJSONArrayLogs: should send with retry for json-string-array type record', async () => {
    // given
    const logs = ['{"message": "message one"}', '{"message": "message two"}'];

    const context = {
      executionContext: {functionName: 'myFuncName'},
    };
    const forwarder = new logForwarder.forTests.EventhubLogForwarder(context);

    const sendWithRetrySpy = jest.spyOn(forwarder, 'sendWithRetry');

    // when
    forwarder.handleJSONArrayLogs(logs, 'json-string-array');

    // then
    expect(sendWithRetrySpy).toHaveBeenCalledTimes(2);
    expect(sendWithRetrySpy).toHaveBeenNthCalledWith(1, {
      message: 'message one',
      ddsource: 'azure',
      ddsourcecategory: 'azure',
      service: 'azure',
      ddtags: 'forwardername:myFuncName',
    });
    expect(sendWithRetrySpy).toHaveBeenNthCalledWith(2, {
      message: 'message two',
      ddsource: 'azure',
      ddsourcecategory: 'azure',
      service: 'azure',
      ddtags: 'forwardername:myFuncName',
    });
  });

  it('handleJSONArrayLogs: should send messaged with retry for buffer-array type record', async () => {
    // given
    const logs = [
      Buffer.from('{"message": "message one"}', 'utf8'),
      Buffer.from('{"message": "message two"}', 'utf8'),
    ];

    const context = {
      executionContext: {functionName: 'myFuncName'},
    };
    const forwarder = new logForwarder.forTests.EventhubLogForwarder(context);

    const sendWithRetrySpy = jest.spyOn(forwarder, 'sendWithRetry');

    // when
    forwarder.handleJSONArrayLogs(logs, 'buffer-array');

    // then
    expect(sendWithRetrySpy).toHaveBeenCalledTimes(2);
    expect(sendWithRetrySpy).toHaveBeenNthCalledWith(1, {
      message: 'message one',
      ddsource: 'azure',
      ddsourcecategory: 'azure',
      service: 'azure',
      ddtags: 'forwardername:myFuncName',
    });
    expect(sendWithRetrySpy).toHaveBeenNthCalledWith(2, {
      message: 'message two',
      ddsource: 'azure',
      ddsourcecategory: 'azure',
      service: 'azure',
      ddtags: 'forwardername:myFuncName',
    });
  });

  it('handleJSONArrayLogs: should send records with retry for buffer-array type record', async () => {
    // given
    const logs = [
      Buffer.from(
        '{\n' +
          '   "records":[\n' +
          '      {\n' +
          '         "resourceId":"/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/providers/Microsoft.Web/sites/crm-dev-cat-app"\n' +
          '      },\n' +
          '      {\n' +
          '         "resourceId":"/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/providers/Microsoft.Web/sites/other-dev-cat-app"\n' +
          '      }\n' +
          '   ]\n' +
          '}',
        'utf8'
      ),
      Buffer.from(
        '{\n' +
          '   "records":[\n' +
          '      {\n' +
          '         "resourceId":"/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/providers/Microsoft.Web/sites/crm-dev-cat-app"\n' +
          '      },\n' +
          '      {\n' +
          '         "resourceId":"/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/providers/Microsoft.Web/sites/other-dev-cat-app"\n' +
          '      }\n' +
          '   ]\n' +
          '}',
        'utf8'
      ),
    ];

    const context = {
      executionContext: {functionName: 'myFuncName'},
    };
    const forwarder = new logForwarder.forTests.EventhubLogForwarder(context);

    const sendWithRetrySpy = jest.spyOn(forwarder, 'sendWithRetry');

    // when
    forwarder.handleJSONArrayLogs(logs, 'buffer-array');

    // then
    expect(sendWithRetrySpy).toHaveBeenCalledTimes(4);
    expect(sendWithRetrySpy).toHaveBeenNthCalledWith(1, {
      resourceId:
        '/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/providers/Microsoft.Web/sites/crm-dev-cat-app',
      ddsource: 'azure.web',
      ddsourcecategory: 'azure',
      service: 'azure',
      ddtags:
        'subscription_id:f36e599d-8bf5-4f95-9740-a38a54eb6b98,forwardername:myFuncName',
    });
    expect(sendWithRetrySpy).toHaveBeenNthCalledWith(2, {
      resourceId:
        '/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/providers/Microsoft.Web/sites/other-dev-cat-app',
      ddsource: 'azure.web',
      ddsourcecategory: 'azure',
      service: 'azure',
      ddtags:
        'subscription_id:f36e599d-8bf5-4f95-9740-a38a54eb6b98,forwardername:myFuncName',
    });
    expect(sendWithRetrySpy).toHaveBeenNthCalledWith(3, {
      resourceId:
        '/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/providers/Microsoft.Web/sites/crm-dev-cat-app',
      ddsource: 'azure.web',
      ddsourcecategory: 'azure',
      service: 'azure',
      ddtags:
        'subscription_id:f36e599d-8bf5-4f95-9740-a38a54eb6b98,forwardername:myFuncName',
    });
    expect(sendWithRetrySpy).toHaveBeenNthCalledWith(4, {
      resourceId:
        '/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/providers/Microsoft.Web/sites/other-dev-cat-app',
      ddsource: 'azure.web',
      ddsourcecategory: 'azure',
      service: 'azure',
      ddtags:
        'subscription_id:f36e599d-8bf5-4f95-9740-a38a54eb6b98,forwardername:myFuncName',
    });
  });

  it('handleJSONArrayLogs: check send messages with retry for json-string-array type record', async () => {
    // given
    const logs = ['{"message": "message one"}', '{"message": "message two"}'];

    const context = {
      executionContext: {functionName: 'myFuncName'},
    };
    const forwarder = new logForwarder.forTests.EventhubLogForwarder(context);

    const sendWithRetrySpy = jest.spyOn(forwarder, 'sendWithRetry');

    // when
    forwarder.handleJSONArrayLogs(logs, 'json-string-array');

    // then
    expect(sendWithRetrySpy).toHaveBeenCalledTimes(2);
    expect(sendWithRetrySpy).toHaveBeenNthCalledWith(1, {
      message: 'message one',
      ddsource: 'azure',
      ddsourcecategory: 'azure',
      service: 'azure',
      ddtags: 'forwardername:myFuncName',
    });
    expect(sendWithRetrySpy).toHaveBeenNthCalledWith(2, {
      message: 'message two',
      ddsource: 'azure',
      ddsourcecategory: 'azure',
      service: 'azure',
      ddtags: 'forwardername:myFuncName',
    });
  });

  it('handleJSONArrayLogs: check send records with retry for json-string-array type record', async () => {
    // given
    const logs = [
      '{\n' +
        '   "records":[\n' +
        '      {\n' +
        '         "message":"message one"\n' +
        '      },\n' +
        '      {\n' +
        '         "message":"message two"\n' +
        '      }\n' +
        '   ]\n' +
        '}',
    ];

    const context = {
      executionContext: {functionName: 'myFuncName'},
    };
    const forwarder = new logForwarder.forTests.EventhubLogForwarder(context);

    const sendWithRetrySpy = jest.spyOn(forwarder, 'sendWithRetry');

    // when
    forwarder.handleJSONArrayLogs(logs, 'json-string-array');

    // then
    expect(sendWithRetrySpy).toHaveBeenCalledTimes(2);
    expect(sendWithRetrySpy).toHaveBeenNthCalledWith(1, {
      message: 'message one',
      ddsource: 'azure',
      ddsourcecategory: 'azure',
      service: 'azure',
      ddtags: 'forwardername:myFuncName',
    });
    expect(sendWithRetrySpy).toHaveBeenNthCalledWith(2, {
      message: 'message two',
      ddsource: 'azure',
      ddsourcecategory: 'azure',
      service: 'azure',
      ddtags: 'forwardername:myFuncName',
    });
  });

  it('handleJSONArrayLogs: should log a warning for buffer-array type record because of not valid json input', async () => {
    // given
    const logs = [
      Buffer.from(
        '{\n' +
          '   "records":\n' +
          '      {\n' +
          '         "resourceId":"/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/providers/Microsoft.Web/sites/crm-dev-cat-app"\n' +
          '      },\n' +
          '      {\n' +
          '         "resourceId":"/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/providers/Microsoft.Web/sites/other-dev-cat-app"\n' +
          '      }\n' +
          '   ]\n' +
          '}',
        'utf8'
      ),
    ];

    const contextMock = jest.fn(() => {
      return {
        log: {
          warn: (str: any) => {
            expect(str).toBe('log is malformed json, sending as string');
          },
        },
        executionContext: {functionName: 'myFuncName'},
      };
    });
    const forwarder = new logForwarder.forTests.EventhubLogForwarder(
      contextMock()
    );

    const sendWithRetrySpy = jest.spyOn(forwarder, 'sendWithRetry');

    // when
    forwarder.handleJSONArrayLogs(logs, 'buffer-array');

    // then
    expect(sendWithRetrySpy).toHaveBeenCalledTimes(1);
    expect(sendWithRetrySpy).toHaveBeenNthCalledWith(1, {
      message:
        '{\n   "records":\n      {\n         "resourceId":"/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/providers/Microsoft.Web/sites/crm-dev-cat-app"\n      },\n      {\n         "resourceId":"/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/providers/Microsoft.Web/sites/other-dev-cat-app"\n      }\n   ]\n}',
      ddsource: 'azure',
      ddsourcecategory: 'azure',
      service: 'azure',
      ddtags: 'forwardername:myFuncName',
    });
  });

  it('handleJSONArrayLogs: should should log a warning for json-string-array type record because of not valid json input', async () => {
    // given
    const logs = [
      '{\n' +
        '   "records":[\n' +
        '      {\n' +
        '         "message":"message one"\n' +
        '      },\n' +
        '      {\n' +
        '         "message":"message two"\n' +
        '      }\n' +
        '   \n' +
        '}',
      '{\n' +
        '   "records":[\n' +
        '      {\n' +
        '         "message":"message one"\n' +
        '      },\n' +
        '      {\n' +
        '         "message":"message two"\n' +
        '      }\n' +
        '   ]\n' +
        '}',
    ];

    const contextMock = jest.fn(() => {
      return {
        log: {
          warn: (str: any) => {
            expect(str).toBe('log is malformed json, sending as string');
          },
        },
        executionContext: {functionName: 'myFuncName'},
      };
    });
    const forwarder = new logForwarder.forTests.EventhubLogForwarder(
      contextMock()
    );

    const sendWithRetrySpy = jest.spyOn(forwarder, 'sendWithRetry');

    // when
    forwarder.handleJSONArrayLogs(logs, 'json-string-array');

    // then
    expect(sendWithRetrySpy).toHaveBeenCalledTimes(3);
    expect(sendWithRetrySpy).toHaveBeenNthCalledWith(1, {
      message:
        '{\n   "records":[\n      {\n         "message":"message one"\n      },\n      {\n         "message":"message two"\n      }\n   \n}',
      ddsource: 'azure',
      ddsourcecategory: 'azure',
      service: 'azure',
      ddtags: 'forwardername:myFuncName',
    });
    expect(sendWithRetrySpy).toHaveBeenNthCalledWith(2, {
      message: 'message one',
      ddsource: 'azure',
      ddsourcecategory: 'azure',
      service: 'azure',
      ddtags: 'forwardername:myFuncName',
    });
    expect(sendWithRetrySpy).toHaveBeenNthCalledWith(3, {
      message: 'message two',
      ddsource: 'azure',
      ddsourcecategory: 'azure',
      service: 'azure',
      ddtags: 'forwardername:myFuncName',
    });
  });

  it('handleLogs: should process string type of messages', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const getLogFormatSpy = jest
      .spyOn(forwarder, 'getLogFormat')
      .mockReturnValue('string');
    const formatLogAndSendSpy = jest
      .spyOn(forwarder, 'formatLogAndSend')
      .mockReturnValue('string');
    const inputLogs: any[] = [];

    // when
    await forwarder.handleLogs(inputLogs);

    // then
    expect(getLogFormatSpy).toHaveBeenCalledTimes(1);
    expect(getLogFormatSpy).toHaveBeenCalledWith(inputLogs);

    expect(formatLogAndSendSpy).toHaveBeenCalledTimes(1);
    expect(formatLogAndSendSpy).toHaveBeenCalledWith('string', inputLogs);
  });

  it('handleLogs: should process json-string type of messages', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const getLogFormatSpy = jest
      .spyOn(forwarder, 'getLogFormat')
      .mockReturnValue('json-string');
    const formatLogAndSendSpy = jest
      .spyOn(forwarder, 'formatLogAndSend')
      .mockReturnValue('string');
    const inputLogs = '{\n' + '   "key":"value"\n' + '}';

    // when
    forwarder.handleLogs(inputLogs);

    // then
    expect(getLogFormatSpy).toHaveBeenCalledTimes(1);
    expect(getLogFormatSpy).toHaveBeenCalledWith(inputLogs);

    expect(formatLogAndSendSpy).toHaveBeenCalledTimes(1);
    expect(formatLogAndSendSpy).toHaveBeenCalledWith('json', {key: 'value'});
  });

  it('handleLogs: should process json-object type of messages', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const getLogFormatSpy = jest
      .spyOn(forwarder, 'getLogFormat')
      .mockReturnValue('json-object');
    const formatLogAndSendSpy = jest
      .spyOn(forwarder, 'formatLogAndSend')
      .mockReturnValue('string');
    const inputLogs = {key: 'value'};

    // when
    forwarder.handleLogs(inputLogs);

    // then
    expect(getLogFormatSpy).toHaveBeenCalledTimes(1);
    expect(getLogFormatSpy).toHaveBeenCalledWith(inputLogs);

    expect(formatLogAndSendSpy).toHaveBeenCalledTimes(1);
    expect(formatLogAndSendSpy).toHaveBeenCalledWith('json', {
      key: 'value',
    });
  });

  it('handleLogs: should process string-array type of messages', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const getLogFormatSpy = jest
      .spyOn(forwarder, 'getLogFormat')
      .mockReturnValue('string-array');
    const formatLogAndSendSpy = jest
      .spyOn(forwarder, 'formatLogAndSend')
      .mockReturnValue('string');
    const inputLogs = ['{"key1": "value1"}', '{"key2": "value2"}'];

    // when
    forwarder.handleLogs(inputLogs);

    // then
    expect(getLogFormatSpy).toHaveBeenCalledTimes(1);
    expect(getLogFormatSpy).toHaveBeenCalledWith(inputLogs);

    expect(formatLogAndSendSpy).toHaveBeenCalledTimes(2);
    expect(formatLogAndSendSpy).toHaveBeenNthCalledWith(
      1,
      'string',
      '{"key1": "value1"}'
    );
    expect(formatLogAndSendSpy).toHaveBeenNthCalledWith(
      2,
      'string',
      '{"key2": "value2"}'
    );
  });

  it('handleLogs: should process json-array type of messages', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const getLogFormatSpy = jest
      .spyOn(forwarder, 'getLogFormat')
      .mockReturnValue('json-array');
    const handleJSONArrayLogsSpy = jest
      .spyOn(forwarder, 'handleJSONArrayLogs')
      .mockReturnValue('string');
    const inputLogs = [{key1: 'value1'}, {key2: 'value2'}];

    // when
    forwarder.handleLogs(inputLogs);

    // then
    expect(getLogFormatSpy).toHaveBeenCalledTimes(1);
    expect(getLogFormatSpy).toHaveBeenCalledWith(inputLogs);

    expect(handleJSONArrayLogsSpy).toHaveBeenCalledTimes(1);
    expect(handleJSONArrayLogsSpy).toHaveBeenNthCalledWith(
      1,
      inputLogs,
      'json-array'
    );
  });

  it('handleLogs: should process buffer-array type of messages', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const getLogFormatSpy = jest
      .spyOn(forwarder, 'getLogFormat')
      .mockReturnValue('buffer-array');
    const handleJSONArrayLogsSpy = jest
      .spyOn(forwarder, 'handleJSONArrayLogs')
      .mockReturnValue('string');
    const inputLogs = [
      Buffer.from('bufStr1', 'utf8'),
      Buffer.from('bufStr2', 'utf8'),
    ];

    // when
    forwarder.handleLogs(inputLogs);

    // then
    expect(getLogFormatSpy).toHaveBeenCalledTimes(1);
    expect(getLogFormatSpy).toHaveBeenCalledWith(inputLogs);

    expect(handleJSONArrayLogsSpy).toHaveBeenCalledTimes(1);
    expect(handleJSONArrayLogsSpy).toHaveBeenNthCalledWith(
      1,
      inputLogs,
      'buffer-array'
    );
  });

  it('handleLogs: should process json-string-array type of messages', async () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const getLogFormatSpy = jest
      .spyOn(forwarder, 'getLogFormat')
      .mockReturnValue('json-string-array');
    const handleJSONArrayLogsSpy = jest
      .spyOn(forwarder, 'handleJSONArrayLogs')
      .mockReturnValue('string');
    const inputLogs = ['{"key": "value"}', '{"key": "value"}'];

    // when
    forwarder.handleLogs(inputLogs);

    // then
    expect(getLogFormatSpy).toHaveBeenCalledTimes(1);
    expect(getLogFormatSpy).toHaveBeenCalledWith(inputLogs);

    expect(handleJSONArrayLogsSpy).toHaveBeenCalledTimes(1);
    expect(handleJSONArrayLogsSpy).toHaveBeenNthCalledWith(
      1,
      inputLogs,
      'json-string-array'
    );
  });

  it("handleLogs: should log warn an don't process some messages", async () => {
    // given
    const contextMock = jest.fn(() => {
      return {
        log: {
          warn: (str: any) => {
            expect(str).toBe('logs format is invalid');
          },
        },
      };
    });
    const forwarder = new logForwarder.forTests.EventhubLogForwarder(
      contextMock()
    );
    const getLogFormatSpy = jest
      .spyOn(forwarder, 'getLogFormat')
      .mockReturnValue('invalid');
    const handleJSONArrayLogsSpy = jest
      .spyOn(forwarder, 'handleJSONArrayLogs')
      .mockReturnValue('string');
    const formatLogAndSendSpy = jest
      .spyOn(forwarder, 'formatLogAndSend')
      .mockReturnValue('string');
    const inputLogs = ['{"key": "value"}', '{"key": "value"}'];

    // when
    forwarder.handleLogs(inputLogs);

    // then
    expect(getLogFormatSpy).toHaveBeenCalledTimes(1);
    expect(getLogFormatSpy).toHaveBeenCalledWith(inputLogs);
    expect(handleJSONArrayLogsSpy).toHaveBeenCalledTimes(0);
    expect(formatLogAndSendSpy).toHaveBeenCalledTimes(0);
  });

  it('scrub: should match pattern and replace some part of record', async () => {
    // given
    const ipRule: Rule = {
      pattern: '[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}',
      replacement: 'xxx.xxx.xxx.xxx',
    };

    const mailRule: Rule = {
      pattern: '[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+',
      replacement: 'yyy@yyy.zz',
    };

    const configs: Config[] = [];

    const ipConfig: Config = {
      name: 'ipConfig',
      rule: ipRule,
    };
    const mailConfig: Config = {
      name: 'mailConfig',
      rule: mailRule,
    };

    configs[0] = ipConfig;
    configs[1] = mailConfig;

    const scrubber = new logForwarder.forTests.Scrubber(undefined, configs);
    const record =
      '/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/resourceGroups/crm-dev-rg/providers/Microsoft.Web/sites/crm-dev-cat-app/mustermann@gmx.de/203.000.113.195';

    // when
    const actual = scrubber.scrub(record);

    // then
    expect(actual).toBe(
      '/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/resourceGroups/crm-dev-rg/providers/Microsoft.Web/sites/crm-dev-cat-app/yyy@yyy.zz/xxx.xxx.xxx.xxx'
    );
  });

  it('scrub: should log error because of malformed mail pattern', async () => {
    // given
    const ipRule: Rule = {
      pattern: '[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}',
      replacement: 'xxx.xxx.xxx.xxx',
    };

    const mailRule: Rule = {
      pattern: '[a-zA-Z0-9_.+-+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.+',
      replacement: 'yyy@yyy.zz',
    };

    const configs: Config[] = [];

    const ipConfig: Config = {
      name: 'ipConfig',
      rule: ipRule,
    };
    const mailConfig: Config = {
      name: 'mailConfig',
      rule: mailRule,
    };

    configs[0] = ipConfig;
    configs[1] = mailConfig;

    const contextMock = jest.fn(() => {
      return {
        log: {
          error: (str: any) => {
            expect(str).toBe(
              'Regexp for rule mailConfig pattern [a-zA-Z0-9_.+-+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.+ is malformed, skipping. Please update the pattern for this rule to be applied.'
            );
          },
        },
      };
    });
    const scrubber = new logForwarder.forTests.Scrubber(contextMock(), configs);
    const record =
      '/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/resourceGroups/crm-dev-rg/providers/Microsoft.Web/sites/crm-dev-cat-app/mustermann@gmx.de/203.000.113.195';

    // when
    const actual = scrubber.scrub(record);

    // then
    expect(actual).toBe(
      '/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/resourceGroups/crm-dev-rg/providers/Microsoft.Web/sites/crm-dev-cat-app/mustermann@gmx.de/xxx.xxx.xxx.xxx'
    );
  });

  /*test("sendWithRetry: should failure", () => {
    // given
    const contextMock = jest.fn(() => {
      return {
        log: {
          error: (str) => {
            expect(str).toBe(
              `unable to sghend request after 2 tries, err: ${err}`
            );
          },
        },
      };
    });
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();

    const promiseMock = mock < Promise > (jest.fn(), jest.fn());
    jest.spyOn(forwarder, "sendWithRetry").mockImplementation(() => {
      return promiseMock;
    });

    expect(forwarder.sendWithRetry(null)).rejects.toThrow(
      new Error(`something weird happened`)
    );
  });*/
});
