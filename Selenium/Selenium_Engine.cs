using System;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.Edge;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium;
using OpenQA.Selenium.BiDi.BrowsingContext;

namespace SeleniumEngine;

public class Selenium_Engine
{
    private IWebDriver ENGINE { get; set; }
    private DriverOptions Opt { get; set; }

    private void Initialize_Browsesettings(string engine_type, bool no_proxy = true)
    {
        switch (engine_type)
        {
            case "firefox":
                this.Opt = new FirefoxOptions();
                ((FirefoxOptions)this.Opt).AcceptInsecureCertificates = true;
                ((FirefoxOptions)this.Opt).AddArgument("--ignore-certificate-errors");
                break;
            case "edge":
                this.Opt = new EdgeOptions();
                ((EdgeOptions)this.Opt).AcceptInsecureCertificates = true;
                ((EdgeOptions)this.Opt).AddArgument("--ignore-certificate-errors");
                break;
            case "chrome":
                this.Opt = new ChromeOptions();
                ((ChromeOptions)this.Opt).AcceptInsecureCertificates = true;
                ((ChromeOptions)this.Opt).AddArgument("--ignore-certificate-errors");
                break;
            default:
                throw new ArgumentException("Unsupported engine type");
        }
        Proxy proxy_srv = new Proxy();

        if (!no_proxy)
        {
            proxy_srv.Kind = ProxyKind.Manual;
            proxy_srv.IsAutoDetect = false;
            proxy_srv.SslProxy = "proxy-srv.in-klr.com:8081";
        }


        this.Opt.Proxy = proxy_srv;
    }
    public void New_Engine(string engine_type )
    {
        ENGINE = engine_type switch
        {
            "firefox" => new FirefoxDriver(),
            "edge" => new EdgeDriver(),
            "chrome" => new ChromeDriver(),
            _ => throw new ArgumentException("Unsupported engine type")
        };
    }
    public IWebDriver Get_Engine()
    {
        return ENGINE;
    }
    
    public void Quit_Engine()
    {
        if (ENGINE != null)
        {
            ENGINE.Quit();
            ENGINE = null;
        }
    }
}