using AE.Net.Mail;
using Google.Apis.Gmail.v1.Data;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChatBotWindowsFunctions
{
    public static class DateTimeHelper
    {
        public static DateTime Parse(string parsable)
        {
            if(string.IsNullOrWhiteSpace(parsable) || parsable.ToLower() == "today")
            {
                return DateTime.Today;
            }
            else if(parsable.ToLower() == "tomorrow")
            {
                return DateTime.Today.AddDays(1);
            }

            DateTime date;
            DateTime.TryParse(parsable,out date);

            return date;
        }
    }

    public static class MessageHelper
    {
        public static Message ToMessage(this MailMessage mail, string threadID = null)
        {
            var strWriter = new StringWriter();
            mail.Save(strWriter);
            var inputBytes = Encoding.UTF8.GetBytes(strWriter.ToString());
            return new Message()
            {
                Raw  = Convert.ToBase64String(inputBytes).Replace("+", "-").Replace("/", "_").Replace("=", ""),
                ThreadId = threadID
            };
        }

        public static MailMessage Reply(this Message mail,string message)
        {
            string subject = GetSubject(mail);

            if (subject.StartsWith("Re:", StringComparison.OrdinalIgnoreCase))
            {
                subject = "Re: " + subject;
            }

            string to = GetSender(mail);
            string messageID = GetValue(mail, "Message-ID");
            string references = GetValue(mail, "References");
            if (!string.IsNullOrEmpty(references))
            {
                references += ' ';
            }

            references += messageID;            

            MailMessage newMessage = new MailMessage()
            {
                From = new System.Net.Mail.MailAddress(GoogleApiFunctions.UserInfo.Email),
                Subject = "Re: " + subject,
                Body = message,
            };

            newMessage.Headers.Add("In-Reply-To", messageID);
            newMessage.Headers.Add("References", references);
            newMessage.To.Add(new System.Net.Mail.MailAddress(to));

            return newMessage;
        }

        private static string GetSubject(Message message)
        {
            return GetValue(message, "Subject");
        }

        private static string GetSender(Message message)
        {
            return GetValue(message, "From");
        }

        private static string GetValue(Message message, string name)
        {
            if (message?.Payload?.Headers != null)
            {
                foreach (var item in message?.Payload?.Headers)
                {
                    if (item.Name == name)
                    {
                        return item.Value;
                    }
                }
            }

            return string.Empty;
        }

        private static string GetContent(Message message)
        {
            StringBuilder stringBuilder = new StringBuilder();
            try
            {
                GetPlainTextFromMessageParts(message?.Payload?.Parts, stringBuilder);
                byte[] data = Convert.FromBase64String(stringBuilder.ToString());
                return Encoding.UTF8.GetString(data);
            }
            catch
            {
                return message.Snippet;
            }
        }

        private static void GetPlainTextFromMessageParts(IList<MessagePart> messageParts, StringBuilder stringBuilder)
        {
            if (messageParts != null)
            {
                foreach (MessagePart messagePart in messageParts)
                {
                    if (messagePart.MimeType == "text/plain")
                    {
                        stringBuilder.Append(messagePart.Body.Data);
                    }

                    if (messagePart.Parts != null)
                    {
                        GetPlainTextFromMessageParts(messagePart.Parts, stringBuilder);
                    }
                }
            }
        }
    }
}
