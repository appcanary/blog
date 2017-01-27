---
title: "Go, imagination, and plagiarism"
date: 2017-01-27
author: mveytsman
layout: post
published: false
thumbnail: images/canary_ledger.png
tags: Programming, Golang
---

I studied computer science in university. It was the mid-aughts, a heady time when American institutions felt like they were in peril. The Bush administration was mired in scandal, The New York times had just booted Jayson Blair for plagiarism and fabulism. A young Hayden Christensen starred in Shattered Glass, telling the story of The New Republic's Stephen Glass, perhaps the most famous producer of what we now call "fake news." He went so far as to create shitty [websites](https://en.wikipedia.org/wiki/Stephen_Glass#/media/File:Stephen_Glass_Jukt_Micronics_site.gif) for non-existent companies, to try to back up his claims.

Both the "Grey Lady" and the "In-flight Magazine of Air Force One" were scandalized by youngsters, who due to the intense pressure or ego or greed decided to throw away everything they learned about good journalism in school and proceed copy, lie, and make facts up. The culprit was obvious: the schools. Rarely was the question asked, how is our children learning to plagiarize? Clearly, we had to teach students that plagiarism was a mortal sin, the earlier the better.

Enter companies like Turnitin &mdash; you submit your essay about the symbolism of Jack's red hair in Lord of the Flies, and a computer algorithm compares it to every other essay ever written on the subject to make sure you're not copy-pasting entire paragraphs from an essay you borrowed from your girlfriend's older brother who took the same class eight years ago. Even if you switch around some paragraphs and reword a few phrases, the algorithm will still catch you[^translation]. If we get the world's best scientists to come up with the world's best diffing algorithms, we can definitely, certainly, completely win war on plagiarism in our schools.

I managed to miss the deployment of Turnitin in high school, and I went to university in Canada, where I got to avoid some of the excesses of the American education system. My humanities classes never had such things and I was free to copy, lie, cheat, and steal with impunity. But my computer science classes were another story. Obviously, that department is going to be ahead of the curve in automating itself out of existence, and our coding assignments were automatically graded. Our professors often told us not to plagiarize. Because they had algorithms. Secret hush-hush algorithms they couldn't share with the students lest they learn how to defeat them, but nevertheless these algorithms could detect if you copied your roommate's older sister's filesystem implementation for your operating systems class. Even if you renamed all the variables rewrote the comments and swapped a couple of lines, the algorithm will still catch you.

I always suspected this was bullshit. The concept of plagiarism doesn't seem to apply to computer science. Algorithms are theorems, they can be discovered, but certainly not stolen. And as for implementations, when I write code I consider good, it has a inevitable feel to it, like the most direct way possible of expressing an idea. I always figured that it was very likely that two equally bright students, when given the same problem and the same constraints, would come up with roughly the same code. My Python implementation of quicksort is going to look almost exactly like every other one in the class, even if we didn't all copy it from each other.

Of course this assumes you're working in a language with a strong emphasis on Only One Way To Do It. If you're marking an assignment written in Lisp, Perl, or Ruby, any sign of similarity whatsoever should be taken as direct evidence of cheating. But in school we mostly used Python, where the above theory holds.

It holds even stronger in Go.

---

[Jonathan](http://j0ni.ca/) is working on some code to help our [agent](https://github.com/appcanary/agent) introspect into processes. Our friend [Andrey](https://twitter.com/shazow) did a big spike last summer, but it hasn't been worked on since, until Jonathan picked it up this year.

Jonathan added a bit of code to correlate running processes with the command used to spawn them and submitted a PR, only to realize that I'd had the same idea back in September, and helpfully left a PR for our future selves. It had been forgotten about and now stood slightly dusty and side-by-side with Jonathan's code.

And the eerie thing is that we, two very different people with different experiences and backgrounds who'd only been working together for a few months wrote almost character for character the *exact same code*!

Here's mine:

```diff
type process struct {
 	pid     int
 	started *time.Time
+	command string
 }
 
 // PID returns the process ID.
@@ -50,6 +51,23 @@ func (p *process) Started() (time.Time, error) {
 	return started, nil
 }
 
+// Command uses `ps` to query the command of the process.
+func (p *process) Command() (string, error) {
+	if p.command != "" {
+		return p.command, nil
+	}
+
+	cmd := exec.Command("ps", "-p", fmt.Sprintf("%d", p.PID()), "-o", "cmd=")
+	out, err := cmd.Output()
+	if err != nil {
+		return "", err
+	}
+
+	command := strings.TrimSpace(string(out))
+	p.command = command
+	return command, nil
+}
+
```

And here's his:

```diff
type process struct {
 	pid     int
 	started *time.Time
+	command string
 }
 
 // PID returns the process ID.
 func (p *process) PID() int {
 	return p.pid
 }
 
+// Command returns the full command line string used to invoke the process.
+func (p *process) Command() (string, error) {
+	if p.command != "" {
+		return p.command, nil
+	}
+
+	cmd := exec.Command("ps", "-p", fmt.Sprintf("%d", p.PID()), "-o", "args=")
+	out, err := cmd.Output()
+	if err != nil {
+		return "", err
+	}
+
+	p.command = strings.TrimSpace(string(out))
+	return p.command, nil
+}
+
```

You'll notice that the only difference is the arguments passed to `ps`. The only place we deviate from each other is when we leave Go for a shell command!

Obviously, this is a minuscule chunk of code. If we'd had written something larger that was as similar, I'd start to question my sanity. But, at the scale of a function, it does really feel like there's Only One Way To Do It in Go. More so than any other language I'd worked with.

Jonathan's take was that this is further evidence that Go is a "zero-imagination language." I agree, but see it as a more of a good thing than I think he does. Having a language where there's so obviously only one way to write a given function is refreshing, especially after using a lot of [clojure](https://blog.appcanary.com/2016/missing-clojure.html). 

Now let's be clear. Do I only want to write Go for the rest of my life? Of course not. But I see the appeal of Only One Way To Do It.

Especially when you consider the history of Go. Go was designed by Google, which employs a lot of people to write a lot of code. This is a hard management problem, and life would be much easier if they could take recent Ivy-grads[^ivy] and plug them in like Legos into teams. Make them productive as quickly as possible. This becomes possible when there's Only One Way To Do It, and Go is that language . So much so that the language enforces whitespace not in an "Enhancement Proposal" but in the standard tooling. If two programmers write the same function, that means they'll come to speed on each other's code that much faster. Just think of the time-saving when it comes to code review. No choice means no engineers are yelling about the correct way to do something.

Which brings me back to plagiarism. I sincerely hope that my university gave up on the pipe-dream of plagiarism detection for coding assignments. Because if you teach a highly-employable language[^language] where there's Only One Way To Do It, it's inherently impossible. And I definitely think Go is a great teaching language[^language]. Let those students that want to copy each other do it, they'll end up copying from Stack Overflow when they graduate anyway. The ones that want to do it themselves will end up writing the same thing anyway. 

As to all the effort my professors spent on writing AST diffing algorithms, I wish they'd spent it on something else. Maybe on teaching me some actually useful software engineering skills that I never learned, like "how to figure out how long this fucking feature will take."


[^translation]: A guy I knew had a clever algorithm of his own to defeat the graders. He had a talent for languages that exceeded his desire to write papers, so he would just go to the library and find primary sources in German that couldn't have possibly been added to Turnitin's database, and then he'd then translate them into English.

[^ivy]: And Stanford. And Berkeley. Waterloo if they're Canadian.

[^language]: Ideal curriculum: implement a lisp interpreter in it.







