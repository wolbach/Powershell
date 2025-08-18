// See https://aka.ms/new-console-template for more information
using System;
using OpenQA.Selenium;
using OpenQA.Selenium.Edge;
using OpenQA.Selenium.Firefox;

namespace SeleniumTest;

public class TestScript
{
    private static string GetEdgeLocation()
        {
            return Environment.GetEnvironmentVariable("EDGE_BIN");
        }
    public static void Main()
    {

        //EdgeOptions browseSettings = new EdgeOptions();
        

        FirefoxOptions browseSettings = new FirefoxOptions();
        Proxy proxy_srv = new Proxy();

        proxy_srv.Kind = ProxyKind.Manual;
        proxy_srv.IsAutoDetect = false;
        proxy_srv.SslProxy = "proxy-srv.in-klr.com:8081";

        browseSettings.Proxy = proxy_srv;
        browseSettings.AddArgument("ignore-certificate-errors");
        browseSettings.AcceptInsecureCertificates = true;
        //browseSettings.BinaryLocation = TestScript.GetEdgeLocation();

        //IWebDriver driv = new EdgeDriver(browseSettings);
        var driv = new FirefoxDriver(browseSettings);

        driv.Navigate().GoToUrl("https://10.20.32.247/cgi-bin/login");

        var username_box = driv.FindElement(By.ClassName("login-email-input__input"));

        username_box.SendKeys("admin");

        driv.Manage().Timeouts().ImplicitWait = TimeSpan.FromSeconds(10);

        driv.Quit();
    }
}