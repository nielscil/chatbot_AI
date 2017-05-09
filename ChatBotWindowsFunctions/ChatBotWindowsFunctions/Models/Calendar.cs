using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChatBotWindowsFunctions.Models
{
    public class Calendar
    {
        public string Id { get; private set; }
        public string Summary { get; private set; }
        private string Description { get; set; }
        private string Location { get; set; }

        public Calendar(Google.Apis.Calendar.v3.Data.CalendarListEntry cal)
        {
            Id = cal.Id;
            Summary = cal.Summary;
            Description = cal.Description;
            Location = cal.Location;
        }
    }
}
