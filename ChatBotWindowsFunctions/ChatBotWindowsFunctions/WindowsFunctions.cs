using AudioSwitcher.AudioApi.CoreAudio;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChatBotWindowsFunctions
{
    public static class WindowsFunctions
    {
        private static CoreAudioDevice _defaultAudioDevice;
        public static CoreAudioDevice DefaultAudioDevice
        {
            get
            {
                if(_defaultAudioDevice == null)
                {
                    _defaultAudioDevice = new CoreAudioController().DefaultPlaybackDevice;
                }
                return _defaultAudioDevice;
            }
        }

        public static int DecreaseVolume(int decrease)
        {
            double volume = DefaultAudioDevice.Volume;

            DefaultAudioDevice.Volume -= decrease;
            return (int)DefaultAudioDevice.Volume;
        }

        public static int IncreaseVolume(int increase)
        {
            double volume = DefaultAudioDevice.Volume;

            DefaultAudioDevice.Volume += increase;
            return (int)DefaultAudioDevice.Volume;
        }

        public static int SetVolume(int level)
        {
            if(level >= 0 && level <= 100)
            {
                DefaultAudioDevice.Volume = level;
            }
            return (int)DefaultAudioDevice.Volume;
        }

        public static bool Mute(bool mute)
        {
            return DefaultAudioDevice.Mute(mute);
        }
    }
}
