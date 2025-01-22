const wdio = require("webdriverio");

const opts = {
    path: "/",
    port: 4723,
    capabilities: {
        platformName: "Android",
        "appium:deviceName": "emulator-5554",
        "appium:app": "C:/Users/Xerks/OneDrive/Pulpit/BuildBuddy/mobile/build/app/outputs/flutter-apk/app-debug.apk",
        "appium:automationName": "UiAutomator2",
    },
};

(async () => {
    const driver = await wdio.remote(opts);

    try {
        console.log("Rozpoczęcie testu logowania");
        // Wprowadź e-mail
        const emailField = await driver.$('android=new UiSelector().className("android.widget.EditText").instance(0)');
        await emailField.click();
        await driver.pause(1000); // 1 sekunda pauzy
        await emailField.setValue("labuda@gmail.com");
        const emailValue = await emailField.getText();
        console.log("Email field value:", emailValue); 

        const passwordField = await driver.$('android=new UiSelector().className("android.widget.EditText").instance(1)');
        await passwordField.click();
        await driver.pause(1000); // 1 sekunda pauzy
        await passwordField.addValue("haslo123");
        const passwordValue = await passwordField.getText();
        console.log("Password field value:", passwordValue); 

        const loginButton = await driver.$('android=new UiSelector().description("Log in")');
        await loginButton.click();

    } catch (err) {
        console.error("Błąd podczas testu logowania:", err);
    }
})();
