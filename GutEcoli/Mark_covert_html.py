from markdown import markdown

file = open('help.md','r').read()

html=markdown(file)
print(html)
with open('ret.html','w')as file:
	file.write(html)
