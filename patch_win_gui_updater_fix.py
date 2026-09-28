with open("/tmp/wingui2/main.go", "r") as f:
    text = f.read()

text = text.replace('ans, _ := zenity.Question', 'errUpdate := zenity.Question')
text = text.replace('if ans == nil', 'if errUpdate == nil')

with open("/tmp/wingui2/main.go", "w") as f:
    f.write(text)
