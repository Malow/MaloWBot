using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Windows.Forms;
using System.Windows.Input;
using System.Runtime.InteropServices;
using System.ComponentModel;

namespace CSharpPresser
{
    class AccountInfo
    {
        public string accountName;
        public string password;
        public string characterName;
    }

    class DataFile
    {
        public string gamePath;
        public List<AccountInfo> accounts;
        public Dictionary<string, List<string>> setups;

        public DataFile()
        {
            this.gamePath = "C:\\Games\\World of Warcraft 1.12 - Multibox\\WoW219.exe";
            accounts = new List<AccountInfo>();
            setups = new Dictionary<string, List<string>>();
        }
    }

    class WoWInstance
    {
        public Process proc;
        public String accountName;
        public String password;
        public String charName;

        public WoWInstance(Process proc, String accountName, String password, String charName)
        {
            this.proc = proc;
            this.accountName = accountName;
            this.password = password;
            this.charName = charName;
        }
    }

    class WoWStarter
    {
        [DllImport("user32.dll", SetLastError = true)]
        static extern bool SetForegroundWindow(IntPtr hWnd);

        private static DataFile ReadDataFile()
        {
            string configFile = "config.txt";
            if (!File.Exists(@configFile))
            {
                DataFile dataFile = new DataFile();
                File.WriteAllText(@configFile, JsonConvert.SerializeObject(dataFile, Formatting.Indented));
            }
            return JsonConvert.DeserializeObject<DataFile>(File.ReadAllText(@configFile));
        }

        public static List<WoWInstance> instances;
        public static DataFile dataFile;

        private static AccountInfo GetAccountInfoForCharacter(string characterName)
        {
            foreach (AccountInfo entry in dataFile.accounts)
            {
                if(entry.characterName == characterName)
                {
                    return entry;
                }
            }
            return null;
        }

        public static void StartWoWs(string setup)
        {
            Console.WriteLine("Starting all WoWs, wait a bit");
            dataFile = ReadDataFile();
            instances = new List<WoWInstance>();

            List<string> characters;
            if(!dataFile.setups.TryGetValue(setup, out characters))
            {
                Console.WriteLine("Couldn't find a setup named " + setup);
                return;
            }
            foreach(string characterName in characters)
            {
                AccountInfo accInfo = GetAccountInfoForCharacter(characterName);
                if(accInfo != null)
                {
                    Console.WriteLine("Starting WoW for " + characterName);
                    Process proc = Process.Start(dataFile.gamePath);
                    instances.Add(new WoWInstance(proc, accInfo.accountName, accInfo.password, accInfo.characterName));
                    System.Threading.Thread.Sleep(500);
                }
                else
                {
                    Console.WriteLine("ERROR: Couldn't find an account for character " + characterName);
                }
            }
            System.Threading.Thread.Sleep(5000);
            Console.WriteLine("Starting typing in details");
            foreach (WoWInstance instance in instances)
            {
                foreach(char c in instance.accountName)
                {
                    Functions.SendKeyDown(GetKeysFromStr(c.ToString().ToUpper()), instance.proc);
                    System.Threading.Thread.Sleep(5);
                }
                System.Threading.Thread.Sleep(250);
                Functions.SendKeyDown(Keys.Tab, instance.proc);
                System.Threading.Thread.Sleep(250);
                foreach (char c in instance.password)
                {
                    Functions.SendKeyDown(GetKeysFromStr(c.ToString().ToUpper()), instance.proc);
                    System.Threading.Thread.Sleep(5);
                }
                System.Threading.Thread.Sleep(500);
                Functions.SendKeyDown(Keys.Enter, instance.proc);
            }
            System.Threading.Thread.Sleep(5000);
            Console.WriteLine("Starting entering characters");
            for (int i = 0; i < 10; i++)
            {
                foreach (WoWInstance instance in instances)
                {
                    Functions.SendKeyDownUp(Keys.Enter, instance.proc);
                }
            }
            Console.WriteLine("Finished starting " + instances.Count + " WoWs");
        }

        public static bool BringCharacterToForeground(string charName)
        {
            foreach (WoWInstance instance in instances)
            {
                if(instance.charName.ToLower().StartsWith(charName.ToLower()))
                {
                    SetForegroundWindow(instance.proc.MainWindowHandle);
                    return true;
                }
            }
            return false;
        }

        public static void CloseWoWs()
        {
            int count = instances.Count;
            foreach (WoWInstance instance in instances)
            {
                try
                {
                    instance.proc.Kill();
                }
                catch (Exception e)
                {
                }
            }
            Console.WriteLine("Finished closing " + count + " WoWs");
        }

        private static Keys GetKeysFromStr(string keystr)
        {
            int whatevs;
            if(Int32.TryParse(keystr, out whatevs))
            {
                keystr = "D" + keystr;
            }
            return (Keys)Enum.Parse(typeof(Keys), keystr);
        }
    }
}
