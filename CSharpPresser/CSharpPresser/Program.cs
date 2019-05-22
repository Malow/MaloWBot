using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.ComponentModel;
using System.Windows.Forms;
using System.Threading;
using System.Drawing;

/* TODO:
 *
 *
 * */
namespace CSharpPresser
{
    public partial class Program
    {
        [DllImport("user32.dll")]
        private static extern IntPtr GetForegroundWindow();
        [DllImport("user32.dll")]
        private static extern int SendMessage(IntPtr hWnd, int uMsg, int wParam, Int32 lParam);
        [DllImport("user32.dll", SetLastError = true)]
        static extern bool PostMessage(IntPtr hWnd, uint Msg, int wParam, int lParam);
        [DllImport("user32.dll", SetLastError = true)]
        static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
        [DllImport("User32.dll")]
        private static extern short GetAsyncKeyState(int vKey);
        [DllImport("user32.dll")]
        static extern bool ClientToScreen(IntPtr hWnd, ref Point lpPoint);
        [DllImport("user32.dll", SetLastError = true)]
        public static extern bool SetCursorPos(int X, int Y);

        private static bool startWoWs = false;
        private static string setupToStart = "";
        private static string bringToForeground = "";
        private static bool closeWoWs = false;

        static void Main(string[] args)
        {
                Program program = new Program();
                new Thread(() =>
                {
                    Thread.CurrentThread.IsBackground = true;
                    try
                    {
                        program.Run();
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine(e.ToString());
                        Console.WriteLine("Please restart the application");
                    }
                }).Start();
                string input = "";
                while (input != "exit")
                {
                    input = Console.ReadLine();
                    if (input.StartsWith("start "))
                    {
                        setupToStart = input.Replace("start ", "");
                        startWoWs = true;
                    }
                    else if (input == "closeall")
                    {
                        closeWoWs = true;
                    }
                    else
                    {
                        bringToForeground = input;
                    }
                }
        }

        public Program()
        {
            Console.WriteLine("F9 toggles the bot on/off");
            Console.WriteLine("F10 toggles the bot sending keys to active WoW on/off");
            Console.WriteLine("Press F11 to perform a spread");
            Console.WriteLine("Press F12 to do a little move forward and jump with all background-WoWs");
            Console.WriteLine("Hold F8 to make the chars hold \"S\"");
            Console.WriteLine("F6 makes them all right-click");
            Console.WriteLine("F7 makes them all do a longer half-circle-spread");
            Console.WriteLine("F8 makes them all backpeddal");
            Console.WriteLine("To start clients type \"start X\" where X corresponds to a text-file in the folder containing account-info");
            Console.WriteLine("To close the clients type \"closeall\"");
            Console.WriteLine("To bring a specific WoW to the foreground type the start of the character's name");
        }

        public bool doMainWindow = false;
        public long last7Press = 0;
        public bool isBackpeddling = false;
        public void Run()
        {
            bool isRunning = false;
            while (true)
            {
                if (isRunning)
                {
                    long now = DateTime.Now.Ticks / TimeSpan.TicksPerMillisecond;
                    if (last7Press + 100 < now)
                    {
                        SendKeyUpToAll(Keys.D9);
                        SendKeyToAll(Keys.D7);
                        SendKeyDownToAll(Keys.D9);
                        last7Press = now;
                    }
                    System.Threading.Thread.Sleep(1 + processes.Count);
                }
                if (IsPressed(Keys.F9))
                {
                    isRunning = !isRunning;
                    if (isRunning)
                    {
                        Console.WriteLine("Bot Started");
                        SetProcesses();
                    }
                    else
                    {
                        Console.WriteLine("Bot Stopped");
                        SendKeyUpToAll(Keys.D9);
                    }
                    System.Threading.Thread.Sleep(1000);
                }
                if (IsPressed(Keys.F10))
                {
                    doMainWindow = !doMainWindow;
                    if (doMainWindow)
                        Console.WriteLine("Started sending to main-mindow");
                    else
                        Console.WriteLine("Stopped sending to main-mindow");
                    System.Threading.Thread.Sleep(1000);
                }
                if (startWoWs)
                {
                    startWoWs = false;
                    if (isRunning)
                    {
                        isRunning = false;
                        Console.WriteLine("Bot Stopped");
                        SendKeyUpToAll(Keys.D9);
                    }
                    WoWStarter.StartWoWs(setupToStart);
                }
                if (closeWoWs)
                {
                    closeWoWs = false;
                    if (isRunning)
                    {
                        isRunning = false;
                        Console.WriteLine("Bot Stopped");
                        SendKeyUpToAll(Keys.D9);
                    }
                    WoWStarter.CloseWoWs();
                }
                if (bringToForeground != "")
                {
                    if (!WoWStarter.BringCharacterToForeground(bringToForeground))
                    {
                        Console.WriteLine("Couldn't find instance with charactername starting with: " + bringToForeground);
                    }
                    bringToForeground = "";
                }
                if (IsPressed(Keys.F6))
                {
                    //DoRightMouseClick();
                    SendKeyToAll(Keys.D8);
                    Console.WriteLine("Sending 8 and Right-mousebutton everywhere on all background WoWs");
                    System.Threading.Thread.Sleep(2000); // Let camera zoom in from the 8-press
                    SendKeyToAll(Keys.D0);
                }
                if (IsPressed(Keys.F7))
                {
                    DoLongerHalfSpread();
                }
                if (IsPressed(Keys.F8))
                {
                    if(!isBackpeddling)
                    {
                        StartBackpeddling();
                        isBackpeddling = true;
                    }
                }
                else if(isBackpeddling)
                {
                    StopBackpeddling();
                    isBackpeddling = false;
                }
                if (IsPressed(Keys.F11))
                {
                    DoSpread();
                }
                if (IsPressed(Keys.F12))
                {
                    Console.WriteLine("Performing movement");
                    System.Threading.Thread.Sleep(1000);
                    DoMovementThing();
                }
            }
        }

        public static List<Process> processes = new List<Process>();
        public static Process mainProcess;
        public static void SetProcesses()
        {
            processes = new List<Process>();
            Process[] procs = Process.GetProcesses();
            for (int i = 0; i < procs.Length; i++)
            {
                if (procs[i].MainWindowTitle == "World of Warcraft")
                {
                    if ((int)procs[i].MainWindowHandle == (int)GetForegroundWindow())
                    {
                        mainProcess = procs[i];
                    }
                    else
                    {
                        processes.Add(procs[i]);
                    }
                }
            }
            Console.WriteLine("Processes set successfully!");
        }

        public static bool IsPressed(Keys key)
        {
            short keyState = GetAsyncKeyState((int)key);
            return ((keyState >> 15) & 0x0001) == 0x0001;
        }

        private void SendKeyToAll(Keys key)
        {
            foreach(Process process in processes)
            {
                Functions.SendKeyDownUp(key, process);
            }
            if(doMainWindow)
            {
                Functions.SendKeyDownUp(key, mainProcess);
            }
        }

        private void SendKeyDownToAll(Keys key)
        {
            foreach (Process process in processes)
            {
                Functions.SendKeyDown(key, process);
            }
            if (doMainWindow)
            {
                Functions.SendKeyDown(key, mainProcess);
            }
        }

        private void SendKeyUpToAll(Keys key)
        {
            foreach (Process process in processes)
            {
                Functions.SendKeyUp(key, process);
            }
            if (doMainWindow)
            {
                Functions.SendKeyUp(key, mainProcess);
            }
        }

        private void DoMovementThing()
        {
            foreach (Process process in processes)
            {
                Functions.SendKeyDown(Keys.W, process);
            }
            if (doMainWindow)
            {
                Functions.SendKeyDown(Keys.W, mainProcess);
            }
            System.Threading.Thread.Sleep(100);
            foreach (Process process in processes)
            {
                Functions.SendKeyDownUp(Keys.Space, process);
            }
            if (doMainWindow)
            {
                Functions.SendKeyDownUp(Keys.Space, mainProcess);
            }
            System.Threading.Thread.Sleep(1000);

            foreach (Process process in processes)
            {
                Functions.SendKeyUp(Keys.W, process);
            }
            if (doMainWindow)
            {
                Functions.SendKeyUp(Keys.W, mainProcess);
            }
        }

        public void StartBackpeddling()
        {
            foreach (Process process in processes)
            {
                Functions.SendKeyDown(Keys.S, process);
            }
            if (doMainWindow)
            {
                Functions.SendKeyDown(Keys.S, mainProcess);
            }
        }

        public void StopBackpeddling()
        {
            foreach (Process process in processes)
            {
                Functions.SendKeyUp(Keys.S, process);
            }
            if (doMainWindow)
            {
                Functions.SendKeyUp(Keys.S, mainProcess);
            }
        }

        private static Random rng = new Random();

        public static List<Process> lastRandomizedOrder = new List<Process>();
        public void DoSpread()
        {
            /* F11->spread, hold "RightArrow" for (2000ms / number of wows) *wowinstance# (randomized order), then hold W for 1 second
	                then you set follow again to make them face you, and then you disable follow and hold some key to make them all hold S while you hold the key */

            List<Process> procs = new List<Process>(processes);
            procs = procs.OrderBy(a => rng.Next()).ToList();
            int count = procs.Count;
            for(int i = 0; i < count; i++)
            {
                Functions.SendKeyDown(Keys.D, procs[i]);
            }
            for (int i = 0; i < count; i++)
            {
                System.Threading.Thread.Sleep(2000 / count);
                Functions.SendKeyUp(Keys.D, procs[i]);
            }
            for (int i = 0; i < count; i++)
            {
                Functions.SendKeyDown(Keys.W, procs[i]);
            }
            System.Threading.Thread.Sleep(1000);
            for (int i = 0; i < count; i++)
            {
                Functions.SendKeyUp(Keys.W, procs[i]);
            }
            lastRandomizedOrder = procs;
        }

        public void DoLongerHalfSpread()
        {
            /* F11->spread, hold "RightArrow" for (2000ms / number of wows) *wowinstance# (randomized order), then hold W for 1 second
	                then you set follow again to make them face you, and then you disable follow and hold some key to make them all hold S while you hold the key */

            List<Process> procs = new List<Process>(processes);
            procs = procs.OrderBy(a => rng.Next()).ToList();
            int count = procs.Count;
            for (int i = 0; i < count; i++)
            {
                Functions.SendKeyDown(Keys.D, procs[i]);
            }
            for (int i = 0; i < count; i++)
            {
                System.Threading.Thread.Sleep(1000 / count);
                Functions.SendKeyUp(Keys.D, procs[i]);
            }
            for (int i = 0; i < count; i++)
            {
                Functions.SendKeyDown(Keys.W, procs[i]);
            }
            System.Threading.Thread.Sleep(3500);
            for (int i = 0; i < count; i++)
            {
                Functions.SendKeyUp(Keys.W, procs[i]);
            }
            lastRandomizedOrder = procs;
        }

        private void DoLeftMouseClick()
        {
            SendKeyToAll(Keys.D8);
            Console.WriteLine("Sending 8 and Right-mousebutton everywhere on all background WoWs");
            System.Threading.Thread.Sleep(2000); // Let camera zoom in from the 8-press
            InteractMouse.SendMouseSpamToAll(Keys.LButton);
        }

        private void DoRightMouseClick()
        {
            SendKeyToAll(Keys.D8);
            Console.WriteLine("Sending 8 and Right-mousebutton everywhere on all background WoWs");
            System.Threading.Thread.Sleep(2000); // Let camera zoom in from the 8-press
            InteractMouse.SendMouseSpamToAll(Keys.RButton);
        }
    }
}
