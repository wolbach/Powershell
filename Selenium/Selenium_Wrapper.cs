// See https://aka.ms/new-console-template for more information
using System;
using OpenQA.Selenium;
using OpenQA.Selenium.BiDi.BrowsingContext;
using OpenQA.Selenium.BiDi.Script;
using OpenQA.Selenium.Edge;
using OpenQA.Selenium.Firefox;
using SeleniumEngine;

namespace SeleniumWrapper;

public class Selenium_Wrapper
{
    private string target_url;

    /* private static string GetEdgeLocation()
    {
        return Environment.GetEnvironmentVariable("EDGE_BIN");
    } */

    public void set_target_url(string url)
    {
        this.target_url = url;
    }

    public string get_target_url()
    {
        return this.target_url;
    }
    public void start_run(bool no_proxy, Selenium_Engine source_driver)
    {

        //EdgeOptions browseSettings = new EdgeOptions();


        

        //browseSettings.BinaryLocation = TestScript.GetEdgeLocation();

        //IWebDriver source_driver = new EdgeDriver(browseSettings);

        IWebDriver current_driver = source_driver.Get_Engine();
        // https://10.20.32.247/cgi-bin/login
        current_driver.Navigate().GoToUrl($"{this.target_url}");

        var username_box = current_driver.FindElement(By.ClassName("login-email-input__input"));

        username_box.SendKeys("admin");

        current_driver.Manage().Timeouts().ImplicitWait = TimeSpan.FromSeconds(10);

        current_driver.Quit();
    }
}

