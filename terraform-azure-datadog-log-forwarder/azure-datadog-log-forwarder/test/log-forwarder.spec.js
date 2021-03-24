describe("log-forwarder", () => {
  const OLD_ENV = process.env;
  const logForwarder = require("../src/log-forwarder");

  beforeEach(() => {
    jest.resetModules(); // Most important - it clears the cache
    process.env = { ...OLD_ENV }; // Make a copy
  });

  afterAll(() => {
    process.env = OLD_ENV; // Restore old environment
  });

  test("should log error if DD_API_KEY is not set", async () => {
    // given
    const contextMock = jest.fn(() => {
      return {
        log: {
          error: (str) => {
            expect(str).toBe(
              "You must configure your API key before starting this function (see ## Parameters section)"
            );
          },
        },
      };
    });
    // when / then
    const eventHubMessages = {};
    await logForwarder(contextMock(), eventHubMessages);
  });

  test("should process empty eventHubMessages", async () => {
    // given
    process.env = Object.assign(process.env, { DD_API_KEY: "value" });
    const contextMock = jest.fn(() => {
      return {
        log: {
          error: (str) => {
            expect(str).toBe(
              "You must configure your API key before starting this function (see ## Parameters section)"
            );
          },
        },
        executionContext: {
          functionName: "blah",
        },
      };
    });
    // when / then
    const eventHubMessages = {};
    await logForwarder(contextMock(), eventHubMessages);
  });

  test("isSource: should return true", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    // when
    const actual = forwarder.isSource("microsoft.");
    // then
    expect(actual).toBeTruthy();
  });

  test("isSource: should return false", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    // when
    const actual = forwarder.isSource("not_microsoft.");
    // then
    expect(actual).not.toBeTruthy();
  });

  test("formatSourceType: should change microsoft to azure", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    // when
    const actual = forwarder.formatSourceType("microsoft.");
    // then
    expect(actual).toBe("azure.");
  });

  test("isJsonString: should return true", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const jsonLogInput =
      "{\n" +
      '    "records": [\n' +
      "        {\n" +
      '            "time": "2019-07-15T18:00:22.6235064Z",\n' +
      '            "resourceId": "/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/resourceGroups/crm-dev-rg/providers/Microsoft.Web/sites/crm-dev-cat-app",\n' +
      '            "category": "AppServiceAppLogs",\n' +
      '            "level": "Error",\n' +
      '            "operationName": "Microsoft.DummyProvider/dummyResourceType/dummySubType/dummyAction"\n' +
      "        },\n" +
      "        {\n" +
      '            "time": "2019-07-15T18:01:15.7532989Z",\n' +
      '            "resourceId": "/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/resourceGroups/crm-dev-rg/providers/Microsoft.Web/sites/crm-dev-cat-app",\n' +
      '            "category": "AppServiceAppLogs",\n' +
      '            "level": "Information",\n' +
      '            "operationName": "Microsoft.DummyProvider/dummyResourceType/dummySubType/dummyAction"\n' +
      "        }\n" +
      "    ]\n" +
      "}";
    // when
    const actual = forwarder.isJsonString(jsonLogInput);
    // then
    expect(actual).toBeTruthy();
  });

  test("isJsonString: should return false", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const notJsonLogInput = "not json input";
    // when
    const actual = forwarder.isJsonString(notJsonLogInput);
    // then
    expect(actual).not.toBeTruthy();
  });

  test("createResourceIdArray: should parse resource id of even emitter", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const record = {
      resourceId:
        "/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/resourceGroups/crm-dev-rg/providers/Microsoft.Web/sites/crm-dev-cat-app",
    };
    // when
    const actual = forwarder.createResourceIdArray(record);
    // then
    expect(actual.length).toBe(8);

    expect(actual[0]).toBe("subscriptions");
    expect(actual[1]).toBe("f36e599d-8bf5-4f95-9740-a38a54eb6b98");
    expect(actual[2]).toBe("resourcegroups");
    expect(actual[3]).toBe("crm-dev-rg");
    expect(actual[4]).toBe("providers");
    expect(actual[5]).toBe("microsoft.web");
    expect(actual[6]).toBe("sites");
    expect(actual[7]).toBe("crm-dev-cat-app");
  });

  test("getLogFormat: should return json-string", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const input = "{\n" + '   "key":"value"\n' + "}";
    // when
    const actual = forwarder.getLogFormat(input);
    // then
    expect(actual).toBe("json-string");
  });

  test("getLogFormat: should return string", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const input = "string";
    // when
    const actual = forwarder.getLogFormat(input);
    // then
    expect(actual).toBe("string");
  });

  test("getLogFormat: should return json-object", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const input = { key: "value" };
    // when
    const actual = forwarder.getLogFormat(input);
    // then
    expect(actual).toBe("json-object");
  });

  test("getLogFormat: should return buffer-array", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const input = [
      Buffer.from("bufStr1", "utf8"),
      Buffer.from("bufStr2", "utf8"),
    ];
    // when
    const actual = forwarder.getLogFormat(input);
    // then
    expect(actual).toBe("buffer-array");
  });

  test("getLogFormat: should return json-array", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const input = [{ key: "value" }, { key: "value" }];
    // when
    const actual = forwarder.getLogFormat(input);
    // then
    expect(actual).toBe("json-array");
  });

  test("getLogFormat: should return json-string-array", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const input = ['{"key": "value"}', '{"key": "value"}'];
    // when
    const actual = forwarder.getLogFormat(input);
    // then
    expect(actual).toBe("json-string-array");
  });

  test("getLogFormat: should return string-array ", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const input = ["one message", "two message"];
    // when
    const actual = forwarder.getLogFormat(input);
    // then
    expect(actual).toBe("string-array");
  });

  test("getLogFormat: should return invalid ", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const input = 1;
    // when
    const actual = forwarder.getLogFormat(input);
    // then
    expect(actual).toBe("invalid");
  });

  test("extractMetadataFromResource: should return metadata with empty tags and source because of undefined resourceId", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const input = {};
    // when
    const actual = forwarder.extractMetadataFromResource(input);
    // then
    expect(actual.tags.length).toBe(0);
    expect(actual.source).toBe("");
  });

  test("extractMetadataFromResource: should return metadata with empty tags and source because of resourceId is not a string", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const input = { resourceId: 1 };
    // when
    const actual = forwarder.extractMetadataFromResource(input);
    // then
    expect(actual.tags.length).toBe(0);
    expect(actual.source).toBe("");
  });

  test("extractMetadataFromResource: resource id is of subscriptions type and source is web app -> should add proper tags and source", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const record = {
      resourceId:
        "/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/resourceGroups/crm-dev-rg/providers/Microsoft.Web/sites/crm-dev-cat-app",
    };
    // when
    const actual = forwarder.extractMetadataFromResource(record);
    // then
    expect(actual.tags.length).toBe(2);
    expect(actual.tags[0]).toBe(
      "subscription_id:f36e599d-8bf5-4f95-9740-a38a54eb6b98"
    );
    expect(actual.tags[1]).toBe("resource_group:crm-dev-rg");
    expect(actual.source).toBe("azure.web");
  });

  test("extractMetadataFromResource: source is direct the subscription -> should add proper tags and source", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const record = {
      resourceId: "/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98",
    };
    // when
    const actual = forwarder.extractMetadataFromResource(record);
    // then
    expect(actual.tags.length).toBe(1);
    expect(actual.tags[0]).toBe(
      "subscription_id:f36e599d-8bf5-4f95-9740-a38a54eb6b98"
    );
    expect(actual.source).toBe("azure.subscription");
  });

  test("extractMetadataFromResource: provider-only resource -> should add proper tags and source", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const record = {
      resourceId:
        "/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/providers/Microsoft.Web/sites/crm-dev-cat-app",
    };
    // when
    const actual = forwarder.extractMetadataFromResource(record);
    // then
    expect(actual.tags.length).toBe(1);
    expect(actual.tags[0]).toBe(
      "subscription_id:f36e599d-8bf5-4f95-9740-a38a54eb6b98"
    );
    expect(actual.source).toBe("azure.web");
  });

  test("extractMetadataFromResource: source is the resource group -> should add proper tags and source", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const record = {
      resourceId:
        "/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/resourceGroups/crm-dev-rg",
    };
    // when
    const actual = forwarder.extractMetadataFromResource(record);
    // then
    expect(actual.tags.length).toBe(2);
    expect(actual.tags[0]).toBe(
      "subscription_id:f36e599d-8bf5-4f95-9740-a38a54eb6b98"
    );
    expect(actual.tags[1]).toBe("resource_group:crm-dev-rg");
    expect(actual.source).toBe("azure.resourcegroup");
  });

  test("extractMetadataFromResource: resource is a Azure AD tenant -> should add proper tags and source", () => {
    // given
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const record = {
      resourceId:
        "/tenants/857a7b86-2d66-46f2-92e1-25be0c27e398/providers/Microsoft.aadiam",
    };
    // when
    const actual = forwarder.extractMetadataFromResource(record);
    // then
    expect(actual.tags.length).toBe(1);
    expect(actual.tags[0]).toBe("tenant:857a7b86-2d66-46f2-92e1-25be0c27e398");
    expect(actual.source).toBe("azure.activedirectory");
  });

  test("addTagsToJsonLog: should add proper additional tags", () => {
    // given
    const context = {
      executionContext: { functionName: "myFuncName" },
    };
    const forwarder = new logForwarder.forTests.EventhubLogForwarder(context);
    const record = {
      resourceId:
        "/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/resourceGroups/crm-dev-rg/providers/Microsoft.Web/sites/crm-dev-cat-app",
    };
    // when
    const actual = forwarder.addTagsToJsonLog(record);
    // then
    expect(actual).toMatchObject({
      resourceId:
        "/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/resourceGroups/crm-dev-rg/providers/Microsoft.Web/sites/crm-dev-cat-app",
      ddsource: "azure.web",
      ddsourcecategory: "azure",
      service: "azure",
      ddtags:
        "subscription_id:f36e599d-8bf5-4f95-9740-a38a54eb6b98,resource_group:crm-dev-rg,forwardername:myFuncName",
    });
  });

  test("addTagsToStringLog: should add proper additional tags", () => {
    // given
    const context = {
      executionContext: { functionName: "myFuncName" },
    };
    const forwarder = new logForwarder.forTests.EventhubLogForwarder(context);
    const messageText = "something happened";
    // when
    const actual = forwarder.addTagsToStringLog(messageText);
    // then
    expect(actual).toMatchObject({
      message: "something happened",
      ddsource: "azure",
      ddsourcecategory: "azure",
      service: "azure",
      ddtags: "forwardername:myFuncName",
    });
  });

  test("formatLogAndSend: should send with retry for json type record", () => {
    // given
    const context = {
      executionContext: { functionName: "myFuncName" },
    };
    const forwarder = new logForwarder.forTests.EventhubLogForwarder(context);
    const record = {
      resourceId:
        "/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/providers/Microsoft.Web/sites/crm-dev-cat-app",
    };

    const sendWithRetrySpy = jest.spyOn(forwarder, "sendWithRetry");

    // when
    forwarder.formatLogAndSend("json", record);

    // then
    expect(sendWithRetrySpy).toHaveBeenCalledTimes(1);
    expect(sendWithRetrySpy).toHaveBeenCalledWith({
      resourceId:
        "/subscriptions/f36e599d-8bf5-4f95-9740-a38a54eb6b98/providers/Microsoft.Web/sites/crm-dev-cat-app",
      ddsource: "azure.web",
      ddsourcecategory: "azure",
      service: "azure",
      ddtags:
        "subscription_id:f36e599d-8bf5-4f95-9740-a38a54eb6b98,forwardername:myFuncName",
    });
  });

  test("formatLogAndSend: should send with retry for not json type record", () => {
    // given
    const context = {
      executionContext: { functionName: "myFuncName" },
    };
    const forwarder = new logForwarder.forTests.EventhubLogForwarder(context);
    const messageText = "something happened";

    const sendWithRetrySpy = jest.spyOn(forwarder, "sendWithRetry");

    // when
    forwarder.formatLogAndSend("string", messageText);

    // then
    expect(sendWithRetrySpy).toHaveBeenCalledTimes(1);
    expect(sendWithRetrySpy).toHaveBeenCalledWith({
      message: "something happened",
      ddsource: "azure",
      ddsourcecategory: "azure",
      service: "azure",
      ddtags: "forwardername:myFuncName",
    });
  });
});
