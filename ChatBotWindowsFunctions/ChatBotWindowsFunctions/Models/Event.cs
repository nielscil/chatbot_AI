﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChatBotWindowsFunctions.Models
{
    public class Event
    {
        private string Summary { get; set; }
        private string Description { get; set; }
        private DateTime Start { get; set; }
        private DateTime Stop { get; set; }
        private string Location { get; set; }
        private bool AllDay { get; set; }

        public Event(Google.Apis.Calendar.v3.Data.Event e)
        {
            Summary = e.Summary;
            Description = e.Description;
            Location = e.Location;
            AllDay = !e.Start.DateTime.HasValue || !e.End.DateTime.HasValue;
            Start = e.Start.DateTime.HasValue ? e.Start.DateTime.Value : DateTime.Parse(e.Start.Date);
            Stop = e.End.DateTime.HasValue ? e.End.DateTime.Value : DateTime.Now;
        }

        public override string ToString()
        {
            StringBuilder builder = new StringBuilder();
            if(AllDay)
            {
                builder.AppendLine($"{Summary} | The whole day | {Location}");
            }
            else
            {
                builder.AppendLine($"{Summary} | {Start.ToString("HH:mm")} - {Stop.ToString("HH:mm")} | {Location}");
            }
            builder.AppendLine(Description);
            return builder.ToString();
        }

        public string ToStringWithDate()
        {
            StringBuilder builder = new StringBuilder();
            if (AllDay)
            {
                builder.AppendLine($"{Summary} | {Start.ToString("dd-MM-yyyy")} | {Location}");
            }
            else
            {
                builder.AppendLine($"{Summary} | {Start.ToString("dd-MM-yyyy HH:mm")} - {Stop.ToString("dd-MM-yyyy HH:mm")} | {Location}");
            }
            builder.AppendLine(Description);
            return builder.ToString();
        }
    }
}
