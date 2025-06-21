# Basic Program to open any website Link,
# Code also display some text on TFT screen
# This code works for Windows based PC/Laptop but can be modified for Other OS
import os
import random
import tkinter as tk
from tkinter import messagebox, font

class TrustMeowApp:
    def __init__(self, root):
        self.root = root
        self.root.title("TrustMeow")
        self.root.geometry("500x500")
        self.root.resizable(False, False)
        self.root.configure(bg='black')
        
        # Animation control variables
        self.animation_active = True
        self.cursor_blink_id = None
        self.glitch_animation_id = None
        
        self.create_splash()
    
    def print_cat(self, canvas):
        cat_art = [
            r"   /\_/\ ",
            r"  ( o.o )",
            r"   > ^ < "
        ]
        
        y_pos = 30
        for line in cat_art:
            canvas.create_text(200, y_pos, text=line, font=("Courier", 24), fill="#00ff00")
            y_pos += 40

    def option_selected(self, option):
        if option == 1:
            messagebox.showinfo("Option 1", "Initializing Monero mining protocol...")
        elif option == 2:
            messagebox.showinfo("Option 2", "Accessing darknet subsystems...")
        elif option == 3:
            messagebox.showinfo("Option 3", "Deploying payload...")
        elif option == 4:
            if messagebox.askyesno("Shutdown", "Initiating system self-destruct sequence. Confirm?"):
                os.system("shutdown /s /t 1")
        elif option == 5:
            self.cleanup_animations()
            self.root.destroy()

    def cleanup_animations(self):
        """Stop all animations before destroying widgets"""
        self.animation_active = False
        if self.cursor_blink_id:
            self.root.after_cancel(self.cursor_blink_id)
        if self.glitch_animation_id:
            self.root.after_cancel(self.glitch_animation_id)

    def show_menu(self):
        self.cleanup_animations()
        
        for widget in self.root.winfo_children():
            widget.destroy()
        
        main_frame = tk.Frame(self.root, bg='black')
        main_frame.pack(expand=True, fill='both')
        
        # Create a frame for the animated title
        title_frame = tk.Frame(main_frame, bg='black')
        title_frame.pack(pady=(40, 20))
        
        # Create canvas for glitch effect
        title_canvas = tk.Canvas(title_frame, width=400, height=80, bg='black', highlightthickness=0)
        title_canvas.pack()
        
        # Create the glitch text layers
        self.glitch_texts = []
        colors = ["#00ff00", "#ff00ff", "#00ffff"]
        offsets = [(0, 0), (2, 2), (-2, -2)]
        
        for i in range(3):
            text = title_canvas.create_text(
                200 + offsets[i][0], 
                40 + offsets[i][1], 
                text="TrustMeow", 
                font=("Courier", 24, "bold"), 
                fill=colors[i]
            )
            self.glitch_texts.append(text)
        
        # Restart animation flag
        self.animation_active = True
        self.animate_glitch(title_canvas)
        
        button_frame = tk.Frame(main_frame, bg='black')
        button_frame.pack(expand=True)
        
        button_style = {
            'font': ("Courier", 12),
            'bg': 'black',
            'fg': '#00ff00',
            'activebackground': '#003300',
            'activeforeground': '#00ff00',
            'relief': 'groove',
            'borderwidth': 2,
            'width': 20
        }
        
        options = [
            ("1: Monero Mine", 1),
            ("2: Darknet Access", 2),
            ("3: Payload Deploy", 3),
            ("4: System Shutdown", 4),
            ("5: Exit Terminal", 5)
        ]
        
        for text, opt in options:
            btn = tk.Button(button_frame, text=text, command=lambda o=opt: self.option_selected(o), **button_style)
            btn.pack(pady=8, fill='x')
        
        tk.Frame(main_frame, bg='black', height=40).pack()

    def animate_glitch(self, canvas):
        if not self.animation_active:
            return
            
        # Main text (green) - subtle constant movement
        main_x = 200 + random.uniform(-1.5, 1.5)
        main_y = 40 + random.uniform(-1.5, 1.5)
        canvas.coords(self.glitch_texts[0], main_x, main_y)
        
        # Glitch layers (magenta and cyan) - more pronounced movement
        for i in range(1, 3):
            x_offset = random.uniform(-4, 4)
            y_offset = random.uniform(-4, 4)
            canvas.coords(self.glitch_texts[i], 
                        200 + (2 if i == 1 else -2) + x_offset, 
                        40 + (2 if i == 1 else -2) + y_offset)
        
        # Occasionally change glitch layer colors
        if random.random() < 0.1:
            canvas.itemconfig(self.glitch_texts[1], fill=random.choice(["#ff00ff", "#ffff00", "#ff0000"]))
            canvas.itemconfig(self.glitch_texts[2], fill=random.choice(["#00ffff", "#0000ff", "#ffffff"]))
        
        self.glitch_animation_id = self.root.after(50, lambda: self.animate_glitch(canvas))

    def create_splash(self):
        splash_frame = tk.Frame(self.root, bg='black')
        splash_frame.pack(expand=True, fill='both')
        
        canvas = tk.Canvas(splash_frame, width=400, height=200, bg='black', highlightthickness=0)
        canvas.pack(pady=(80, 20), expand=True)
        self.print_cat(canvas)
        
        loading_font = font.Font(family="Courier", size=14)
        loading_text = tk.Label(splash_frame, text="Initializing TrustMeow v1.337", 
                              font=loading_font, fg="#00ff00", bg='black')
        loading_text.pack(pady=20)
        
        # Blinking cursor
        self.cursor = tk.Label(splash_frame, text="█", font=loading_font, fg="#00ff00", bg='black')
        self.cursor.pack()
        
        self.animation_active = True
        self.blink_cursor()
        self.root.after(2000, self.show_menu)

    def blink_cursor(self):
        if not self.animation_active:
            return
            
        if self.cursor.winfo_exists():  # Check if widget still exists
            current = self.cursor.cget("text")
            self.cursor.config(text="█" if current == "" else "")
        
        self.cursor_blink_id = self.root.after(500, self.blink_cursor)

# Create and run the application
root = tk.Tk()
app = TrustMeowApp(root)
root.mainloop()
