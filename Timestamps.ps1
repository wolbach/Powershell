Add-Type -TypeDefinition @"
using System;
using System.IO;

public class TimeStamps
{
    DateTime lastRun;
    bool isNewDay = false;
    public TimeStamps()
    {
        getLastRun();
        update_isNewDay();
    }

    private void update_isNewDay()
    {
        if (lastRun.Date < DateTime.Today.Date)
        {
            isNewDay = true;

        }
    }

    private string getTime()
    {
        DateTime DT = DateTime.Now;
        string StringDateTime = DT.ToString("yyyy-MM-dd HH:mm:ss");
        return StringDateTime;

    }

    public DateTime getLastRun()
    {
        string lastRunString = Environment.GetEnvironmentVariable("Timestamp_LastRun", EnvironmentVariableTarget.User);
        DateTime.TryParse(lastRunString, out lastRun);
        return lastRun;
    }
    public void setLastRun(DateTime dt)
    {
        Environment.SetEnvironmentVariable("Timestamp_LastRun", dt.ToString(), EnvironmentVariableTarget.User);
        update_isNewDay();
    }

    public void newTimeStamp(string FilePath, string Message)
    {
        if (isNewDay)
                {
                    File.WriteAllText(FilePath, string.Empty);
                    isNewDay = false;
                    setLastRun(DateTime.Today);
                }

        if (System.IO.File.Exists(FilePath))
        {
            string currTime = getTime();
            string tsMessage = String.Format("{0} - {1} ", currTime, Message);
            using (System.IO.FileStream fs = new System.IO.FileStream(FilePath, FileMode.Append, FileAccess.Write))
            {

                

                using (System.IO.StreamWriter sw = new System.IO.StreamWriter(fs))
                {

                    sw.WriteLine(tsMessage);
                }
            }
        }
    }
}

"@ 

$tsWriter = [TimeStamps]::new()
$message = %UserInput%
$filepath = "C:\Users\Markus.Hotz\OneDrive - netgo group GmbH\Dokumente\KnowledgeBase\_Work related\Dailies\Timestamps.md"
$tsWriter.newTimeStamp($filepath, $message)