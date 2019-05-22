using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.ComponentModel;
using System.Windows.Forms;
using System.Drawing;

namespace CSharpPresser
{
    class Functions
    {
        [DllImport("user32.dll", SetLastError = true)]
        static extern bool PostMessage(IntPtr hWnd, uint Msg, int wParam, int lParam);
        [DllImport("user32.dll")]
        static extern bool ScreenToClient(IntPtr hWnd, ref Point lpPoint);

        public static void SendKeyDown(Keys key, Process proc)
        {
            PostMessage(proc.MainWindowHandle, 0x0100, (int)key, 0);
        }

        public static void SendKeyUp(Keys key, Process proc)
        {
            PostMessage(proc.MainWindowHandle, 0x0101, (int)key, 0);
        }

        public static void SendKeyDownUp(Keys key, Process proc)
        {
            PostMessage(proc.MainWindowHandle, 0x0100, (int)key, 0);
            PostMessage(proc.MainWindowHandle, 0x0101, (int)key, 0);
            //System.Threading.Thread.Sleep(1);
        }

        const int WM_LBUTTONDOWN = 0x0201;
        const int WM_LBUTTONUP = 0x0202;
        const int WM_RBUTTONDOWN = 0x0204;
        const int WM_RBUTTONUP = 0x0205;
        const int MK_LBUTTON = 0x0001;
        const int MK_RBUTTON = 0x0002;
        public static void SendMouseDown(Keys key, Process proc, Point point)
        {
            Point cursorPos = point;
            ScreenToClient(proc.MainWindowHandle, ref cursorPos);
            if (key == Keys.RButton)
            {
                PostMessage(proc.MainWindowHandle, WM_RBUTTONDOWN, MK_RBUTTON, MakeLParam(cursorPos.X, cursorPos.Y));
            }
            else if (key == Keys.LButton)
            {
                PostMessage(proc.MainWindowHandle, WM_LBUTTONDOWN, MK_RBUTTON, MakeLParam(cursorPos.X, cursorPos.Y));
            }
        }
        public static void SendMouseUp(Keys key, Process proc, Point point)
        {
            Point cursorPos = point;
            ScreenToClient(proc.MainWindowHandle, ref cursorPos);
            if (key == Keys.RButton)
            {
                PostMessage(proc.MainWindowHandle, WM_RBUTTONUP, 0, MakeLParam(cursorPos.X, cursorPos.Y));
            }
            else if (key == Keys.LButton)
            {
                PostMessage(proc.MainWindowHandle, WM_LBUTTONUP, 0, MakeLParam(cursorPos.X, cursorPos.Y));
            }
        }

        public static int MakeLParam(int LoWord, int HiWord)
        {
            return (int)((HiWord << 16) | (LoWord & 0xFFFF));
        }
    }
}
