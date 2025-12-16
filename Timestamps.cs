using System;
using System.IO;

public class TimeStamps
{
    DateTime lastRun;
    bool isNewDay = false;
    string time;
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

    private string getTime(int timeOffset = 0)
    {
        DateTime DT = DateTime.Now;
        DT = DT.AddMinutes(timeOffset);
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

    public void newTimeStamp(string FilePath, string Message, string time, int timeOffset = 0)
    {
        if (isNewDay)
        {
            File.WriteAllText(FilePath, string.Empty);
            isNewDay = false;
            setLastRun(DateTime.Today);
        }


        if (time.Equals(String.Empty))
        {

            time = getTime(timeOffset);
        }

        if (System.IO.File.Exists(FilePath))
        {

            string tsMessage = String.Format("{0} - {1} ", time, Message);
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