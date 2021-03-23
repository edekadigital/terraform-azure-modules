describe("log-forwarder", () => {
  
  const OLD_ENV = process.env;

  beforeEach(() => {
    jest.resetModules() // Most important - it clears the cache
    process.env = { ...OLD_ENV }; // Make a copy
  });

  afterAll(() => {
    process.env = OLD_ENV; // Restore old environment
  });

  test("should log error if DD_API_KEY is not set", async () => {
    // given
    const contextMock = jest.fn(() => { return {
      log: {
        error: (str) => {
          expect(str).toBe('You must configure your API key before starting this function (see ## Parameters section)')
        }
      }
    }});
    const eventHubMessages = {}
    const logForwarder = require("../src/log-forwarder");
    await logForwarder(contextMock(), eventHubMessages)

  });

  test("should process empty eventHubMessages", async () => {
    // given
    process.env = Object.assign(process.env, { DD_API_KEY: 'value' });
    const contextMock = jest.fn(() => { return {
      log: {
        error: (str) => {
          expect(str).toBe('You must configure your API key before starting this function (see ## Parameters section)')
        }
      },
      executionContext: {
        functionName: "blah"
      }
    }});
    const eventHubMessages = {}
    const logForwarder = require("../src/log-forwarder");
    await logForwarder(contextMock(), eventHubMessages)

  });

  test("isSource: should return true", () => {
    const logForwarder = require("../src/log-forwarder");
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const actual = forwarder.isSource("microsoft.");

    expect(actual).toBeTruthy();
  });

  test("isSource: should return false", () => {
    const logForwarder = require("../src/log-forwarder");
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const actual = forwarder.isSource("not_microsoft.");

    expect(actual).not.toBeTruthy();
  });

  test("formatSourceType: should change microsoft to azure", () => {
    const logForwarder = require("../src/log-forwarder");
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const actual = forwarder.formatSourceType("microsoft.");

    expect(actual).toBe('azure.');
  });
});
