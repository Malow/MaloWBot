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

namespace CSharpPresser
{
    class InteractMouse
    {
        [DllImport("user32.dll", SetLastError = true)]
        static extern bool SetForegroundWindow(IntPtr hWnd);
        [DllImport("user32.dll")]
        public static extern bool GetCursorPos(out POINT lpPoint);
        [DllImport("user32.dll")]
        public static extern bool SetCursorPos(POINT lpPoint);


        [StructLayout(LayoutKind.Sequential)]
        public struct POINT
        {
            public int X;
            public int Y;

            public static implicit operator Point(POINT point)
            {
                return new Point(point.X, point.Y);
            }
        }

        public static Point GetCursorPosition()
        {
            POINT lpPoint;
            GetCursorPos(out lpPoint);
            return lpPoint;
        }

        public static void SendMouseSpamToAll(Keys key)
        {
            Point cursorPos = GetCursorPosition();
            POINT lpPoint;
            lpPoint.X = cursorPos.X;
            lpPoint.Y = cursorPos.Y;
            foreach (Process process in Program.processes)
            {
                Functions.SendMouseDown(key, process, cursorPos);
                System.Threading.Thread.Sleep(100);
                Functions.SendMouseUp(key, process, cursorPos);
                System.Threading.Thread.Sleep(100);
                SetCursorPos(lpPoint);
                System.Threading.Thread.Sleep(100);
            }

            /* OLD BAD STUFF

            long before = DateTime.Now.Ticks / TimeSpan.TicksPerMillisecond;
            while (before + 1000 > DateTime.Now.Ticks / TimeSpan.TicksPerMillisecond)
            {
                Point point = new Point(250, 325);
                ClientToScreen(firstBackgroundWoW.MainWindowHandle, ref point);
                SetCursorPos(point.X, point.Y);
                System.Threading.Thread.Sleep(1);

                foreach (Process process in processes)
                {
                    if (process.MainWindowHandle == GetForegroundWindow() && !doMainWindow)
                        continue;
                    Functions.SendMouseClick(key, process);
                }
            }
            Console.WriteLine("Done");
            const int xStep = 50;
            const int yStep = 50;
            for(int repeat = 1; repeat < 20; repeat++)
            {
                int xOffset = repeat * (xStep / repeat);
                for (int x = 100 + xOffset; x < 300; x += xStep)
                {
                    int yOffset = repeat * (yStep / repeat);
                    for (int y = 200 + yOffset; y < 450; y += yStep)
                    {
                        Point point = new Point(x, y);
                        ClientToScreen(firstBackgroundWoW.MainWindowHandle, ref point);
                        SetCursorPos(point.X, point.Y);
                        System.Threading.Thread.Sleep(1);
                        for (int i = 0; i < processes.Length; i++)
                        {
                            if (processes[i].MainWindowTitle == "World of Warcraft")
                            {
                                if (processes[i].MainWindowHandle == GetForegroundWindow())
                                    continue;

                            }
                        }
                    }
                }
            }*/
        }
    }
}
