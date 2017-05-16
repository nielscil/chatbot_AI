using Google.Apis.Gmail.v1.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChatBotWindowsFunctions.Models
{
    public class Mail
    {
        public string ID { get; set; }
        public string Subject { get; set; }
        public string Sender { get; set; }
        public string To { get; set; }
        public string Message { get; set; }
        public string Snippet { get; set; }
        public DateTime Time { get; set; }
        public bool Empty
        {
            get
            {
                return string.IsNullOrWhiteSpace(Subject) &&
                    string.IsNullOrWhiteSpace(Sender) &&
                    string.IsNullOrWhiteSpace(Message) &&
                    string.IsNullOrWhiteSpace(Snippet);
            }
        }

        public Mail(Message message)
        {
            ID = message.Id;
            Subject = GetSubject(message);
            Sender = GetSender(message);
            Message = GetContent(message);
            To = GetTo(message);
            Snippet = message.Snippet;

            if(message.InternalDate.HasValue)
            {
                DateTime start = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
                Time = start.AddMilliseconds(message.InternalDate.Value).ToLocalTime();
            }     
        }

        private string GetSubject(Message message)
        {
            return GetValue(message, "Subject");
        }

        private string GetTo(Message message)
        {
            return GetValue(message, "To");
        }

        private string GetSender(Message message)
        {
            return GetValue(message, "From");
        }

        private string GetValue(Message message, string name)
        {
            if(message?.Payload?.Headers != null)
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

        private string GetContent(Message message)
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

        private void GetPlainTextFromMessageParts(IList<MessagePart> messageParts, StringBuilder stringBuilder)
        {
            if(messageParts != null)
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

        public string ToString(bool send)
        {
            StringBuilder sb = new StringBuilder();
            if (Time != null)
            {
                if(send)
                {
                    sb.AppendLine($"{Time.ToString("dd-MM-yyyy HH:mm:ss")} | {Subject} | To: {To}");
                }
                else
                {
                    sb.AppendLine($"{Time.ToString("dd-MM-yyyy HH:mm:ss")} | {Subject} | From: {Sender}");
                }
            }
            else
            {
                if(send)
                {
                    sb.AppendLine($"{Subject} | To: {To}");
                }
                else
                {
                    sb.AppendLine($"{Subject} | From: {Sender}");
                }
            }

            sb.AppendLine(Snippet);

            return sb.ToString();
        }
    }
}
