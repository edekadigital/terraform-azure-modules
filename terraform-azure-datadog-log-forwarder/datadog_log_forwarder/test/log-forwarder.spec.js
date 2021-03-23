const logForwarder = require("../src/log-forwarder");

describe("log-forwarder", () => {
  test("isSource: should return true", () => {
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const actual = forwarder.isSource("microsoft.");

    expect(actual).toBeTruthy();
  });

  test("isSource: should return false", () => {
    const forwarder = new logForwarder.forTests.EventhubLogForwarder();
    const actual = forwarder.isSource("not_microsoft.");

    expect(actual).not.toBeTruthy();
  });
});
