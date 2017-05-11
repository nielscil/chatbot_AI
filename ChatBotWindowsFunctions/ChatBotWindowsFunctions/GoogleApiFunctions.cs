using Google.Apis.Auth.OAuth2;
using Google.Apis.Calendar.v3;
using Google.Apis.Calendar.v3.Data;
using Google.Apis.Gmail.v1;
using Google.Apis.Services;
using Google.Apis.Util.Store;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace ChatBotWindowsFunctions
{
    public static class GoogleApiFunctions
    {
        #region Oauth2 details

        private static string[] googleApiScopes = { CalendarService.Scope.Calendar, GmailService.Scope.GmailCompose, GmailService.Scope.GmailSend, GmailService.Scope.GmailReadonly };
        private static string ApplicationName = "Google API's for Chatbot";

        private static UserCredential _credential;
        private static UserCredential Credential
        {
            get
            {
                if(_credential == null)
                {
                    _credential = GetCredential();
                }
                return _credential;
            }
        }

        private static UserCredential GetCredential()
        {
            UserCredential credential = null;

            using (var stream = new FileStream("client_secret.json", FileMode.Open, FileAccess.Read))
            {
                string credPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Personal), ".credentials/chatbot/google.json");

                credential = GoogleWebAuthorizationBroker.AuthorizeAsync(
                    GoogleClientSecrets.Load(stream).Secrets,
                    googleApiScopes,
                    "user",
                    CancellationToken.None,
                    new FileDataStore(credPath, true)).Result;
            }

            return credential;
        }

        private static CalendarService _calendarService;
        private static CalendarService CalendarService
        {
            get
            {
                if (_calendarService == null)
                {
                    _calendarService = new CalendarService(new BaseClientService.Initializer()
                    {
                        HttpClientInitializer = Credential,
                        ApplicationName = ApplicationName,
                    });
                }
                return _calendarService;
            }
        }

        private static GmailService _gmailService;
        private static GmailService GmailService
        {
            get
            {
                if(_gmailService == null)
                {
                    _gmailService = new GmailService(new BaseClientService.Initializer()
                    {
                        HttpClientInitializer = Credential,
                        ApplicationName = ApplicationName,
                    });
                }
                return _gmailService;
            }
        }


        #endregion

        public static Event GetNextEvent()
        {
            return null;
        }

        public static IList<Models.Event> GetUpcomingEvents(string calendar="primary")
        {
            EventsResource.ListRequest request = CalendarService.Events.List(calendar);
            request.TimeMin = DateTime.Now;
            request.TimeMax = DateTime.Today.AddDays(1);
            request.ShowDeleted = false;
            request.SingleEvents = true;
            request.MaxResults = 5;
            request.OrderBy = EventsResource.ListRequest.OrderByEnum.StartTime;
            IList<Models.Event> events = new List<Models.Event>();

            foreach(var e in request.Execute().Items)
            {
                events.Add(new Models.Event(e));
            }

            return events;
        }

        public static IList<Models.Calendar> GetCalendars()
        {
            CalendarListResource.ListRequest request = CalendarService.CalendarList.List();
            request.MaxResults = 10;
            request.ShowDeleted = false;

            IList<Models.Calendar> calendars = new List<Models.Calendar>();

            foreach(var cal in request.Execute().Items)
            {
                calendars.Add(new Models.Calendar(cal));
            }

            return calendars;
        }

        public static Models.Event AddEventToCalendar(string id,string summary, string description, string location,string startDate, string start, string endDate, string end,string timeZone)
        {
            Event e = new Event()
            {
                Summary = summary,
                Location = location,
                Description = description,
                Start = new EventDateTime()
                {
                    DateTime = DateTime.Parse($"{startDate} {start}"),
                    TimeZone = timeZone,
                },
                End = new EventDateTime()
                {
                    DateTime = DateTime.Parse($"{endDate} {end}"),
                    TimeZone = timeZone,
                }
            };
            EventsResource.InsertRequest request = CalendarService.Events.Insert(e,id);
            return new Models.Event(request.Execute());
        }
    }
}
