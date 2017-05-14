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
        public string Message { get; set; }

        public Mail(Message message)
        {
            ID = message.Id;
            Subject = GetSubject(message);
            Sender = GetSender(message);
            Message = GetContent(message);
        }

        private string GetSubject(Message message)
        {
            return GetValue(message, "Subject");
        }

        private string GetSender(Message message)
        {
            return GetValue(message, "From");
        }

        private string GetValue(Message message, string name)
        {
            foreach(var item in message.Payload.Headers)
            {
                if(item.Name == name)
                {
                    return item.Value;
                }
            }

            return string.Empty;
        }

        public string GetContent(Message message)
        {
            StringBuilder stringBuilder = new StringBuilder();
            try
            {
                GetPlainTextFromMessageParts(message.Payload.Parts, stringBuilder);
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
