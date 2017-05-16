using AE.Net.Mail;
using Google.Apis.Auth.OAuth2;

using Google.Apis.Calendar.v3;
using Google.Apis.Calendar.v3.Data;

using Google.Apis.Gmail.v1;
using Google.Apis.Gmail.v1.Data;

using Google.Apis.Oauth2.v2;
using Google.Apis.Oauth2.v2.Data;

using Google.Apis.Services;
using Google.Apis.Util;
using Google.Apis.Util.Store;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net.Mail;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using ChatBotWindowsFunctions;

namespace ChatBotWindowsFunctions
{
    public static class GoogleApiFunctions
    {
        #region Oauth2 details

        private static string[] googleApiScopes = { CalendarService.Scope.Calendar, GmailService.Scope.GmailCompose, GmailService.Scope.GmailSend, GmailService.Scope.GmailReadonly, Oauth2Service.Scope.UserinfoEmail, Oauth2Service.Scope.UserinfoProfile };
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

        private static Oauth2Service _oauthService;
        private static Oauth2Service OauthService
        {
            get
            {
                if(_oauthService == null)
                {
                    _oauthService = new Oauth2Service(new BaseClientService.Initializer()
                    {
                        HttpClientInitializer = Credential,
                        ApplicationName = ApplicationName,
                    });
                }
                return _oauthService;
            }
        }

        private static Userinfoplus _userInfo;
        public static Userinfoplus UserInfo
        {
            get
            {
                if(_userInfo == null)
                {
                    _userInfo = OauthService.Userinfo.Get().Execute();
                }

                return _userInfo;
            }
        }

        private static List<Label> _labels;
        private static List<Label> Labels
        {
            get
            {
                if(_labels == null)
                {
                    UsersResource.LabelsResource.ListRequest request = GmailService.Users.Labels.List(UserInfo.Email);
                    ListLabelsResponse response = request.Execute();
                    _labels = new List<Label>(response.Labels);
                }
                return _labels;
            }
        }

        private static Label Inbox
        {
            get
            {
                foreach(var label in Labels)
                {
                    if(label.Id == "INBOX")
                    {
                        return label;
                    }
                }
                return null;
            }
        }

        #endregion

        #region Calendar

        public static IList<Models.Event> GetUpcomingEvents(string calendar="primary")
        {
            return GetEvents(DateTime.Now, DateTime.Today.AddDays(1),calendar);
        }

        public static IList<Models.Event> GetEvents(string start, string stop, string calendar = "primary")
        {
            DateTime startTime;
            if(string.IsNullOrWhiteSpace(start))
            {
                startTime = DateTime.Now;
            }
            else
            {
                startTime = DateTimeHelper.Parse(start);
            }

            DateTime stopTime;

            if(string.IsNullOrWhiteSpace(stop))
            {
                stopTime = startTime.Date.AddDays(1);
            }
            else
            {
                stopTime = DateTimeHelper.Parse(stop);
            }

            return GetEvents(startTime, stopTime, calendar);
        }

        private static IList<Models.Event> GetEvents(DateTime start, DateTime stop, string calendar= "primary")
        {
            EventsResource.ListRequest request = CalendarService.Events.List(calendar);
            request.TimeMin = start;
            request.TimeMax = stop;
            request.ShowDeleted = false;
            request.SingleEvents = true;
            request.OrderBy = EventsResource.ListRequest.OrderByEnum.StartTime;
            IList<Models.Event> events = new List<Models.Event>();

            foreach (var e in request.Execute().Items)
            {
                events.Add(new Models.Event(e));
            }

            return events;
        }

        public static IList<Models.Calendar> GetCalendars()
        {
            CalendarListResource.ListRequest request = CalendarService.CalendarList.List();
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

        #endregion

        #region Gmail

        public static Models.Mail WriteMail(string mail,string subject, string body)
        {
            AE.Net.Mail.MailMessage message = new AE.Net.Mail.MailMessage()
            {
                Subject = subject,
                Body = body,
                From = new MailAddress(UserInfo.Email)
            };

            foreach(var address in mail.Split(','))
            {
                message.To.Add(new MailAddress(address));
            }

            Message m = GmailService.Users.Messages.Send(message.ToMessage(), UserInfo.Email).Execute();
            return GetMail(m.Id);
        }

        public static Models.Mail Reply(string id, string body)
        {
            Message m = GetMessage(id);
            Models.Mail mail = new Models.Mail(m);

            Message message = m.Reply(body).ToMessage(m.ThreadId);

            Message response = GmailService.Users.Messages.Send(message, UserInfo.Email).Execute();

            return GetMail(response.Id);
        }

        public static IList<Models.Mail> GetMails(bool unread)
        {
            UsersResource.MessagesResource.ListRequest request = GmailService.Users.Messages.List(UserInfo.Email);
            request.LabelIds = new Repeatable<string>(GetLabelIds(unread));

            if(!unread)
            {
                request.MaxResults = 10;
            }

            IList<Models.Mail> mails = new List<Models.Mail>();

            ListMessagesResponse response = request.Execute();
            foreach (var mail in response.Messages)
            {
                mails.Add(GetMail(mail.Id));
            }

            return mails;
        }

        public static Models.Mail GetMail(string id)
        {
            return new Models.Mail(GetMessage(id));
        }

        private static Message GetMessage(string id)
        {
            UsersResource.MessagesResource.GetRequest request = GmailService.Users.Messages.Get(UserInfo.Email, id);
            return request.Execute();
        }

        private static List<string> GetLabelIds(bool unread)
        {
            List<string> list = new List<string>() { "INBOX" };

            if(unread)
            {
                list.Add("UNREAD");
            }

            return list;
        }

        #endregion
    }
}
