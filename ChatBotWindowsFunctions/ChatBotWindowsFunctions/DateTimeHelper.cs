using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChatBotWindowsFunctions
{
    public static class DateTimeHelper
    {
        public static DateTime Parse(string parsable)
        {
            if(string.IsNullOrWhiteSpace(parsable) || parsable.ToUpper() == "today")
            {
                return DateTime.Today;
            }
            else if(parsable.ToUpper() == "tomorrow")
            {
                return DateTime.Today.AddDays(1);
            }

            DateTime date;
            DateTime.TryParse(parsable,out date);

            return date;
        }
    }
}
