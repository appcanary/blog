---
title: "Paper of the month: should you encrypt or compress first?"
date: 2016-06-25
author: mveytsman
layout: post
published: true
---

Imagine this:

You work for a big company. Your job is pretty boring, and frankly your talents are wasted writing boilerplate Java code for an application who's only users are 3 people in accounting who can't stand the sight of you.

Your real passion is security. You read [r/netsec](www.reddit.com/r/netsec) every day and participate in bug bounties after work. For the past 3 months, you've been playing a baroque stock trading game that you're winning because you found a heap-based buffer overflow and wrote some AVR shellcode to help you pick stocks.

You quickly realize that what you thought was a video game was actually a cleverly disguised recruitment tool for the best security consultancy in the world, Mont Piper, and you just landed an interview!

A plane ride and an Uber later, you're sitting across from your potential future boss, a slightly sweaty hacker named Gary in a Norwegian metal band t-shirt and sunglasses he refuses to take off indoors.

You blast through the first part of the interview. You give a great explanation of the difference between privacy and anonymity. You describe the same origin policy in great detail, and give 3 ways an attacker can get around it. You even whiteboard the intricacies of `__fastcall` vs `__stdcall`. Finally, you're at the penultimate section, protocol security.

Gary looks you in the eyes and says: "You're designing a network protocol. Do you compress the data and then encrypt it, or do you encrypt and then compress?" And then he clasps his hands together and smiles to himself.

- - -

Take a second and think about it. 

At a high level, compression seeks to utilize patterns in data in order to reduce its size. Encryption seeks to transform data in such a way that without the key, you can't discern any patterns in the data at all. 

Encryption produces output that appears random, that is it has a high entropy. Compression doesn't really work on data that appears random -- entropy can actually be thought of as a measure of how "compressable" some data is.

So if you encrypt first, your compression will be useless. The answer must be to compress first! Even StackOverflow thinks [so](http://stackoverflow.com/questions/4676095/when-compressing-and-encrypting-should-i-compress-first-or-encrypt-first).

- - -

You start to say this to Gary, but you stop mid-sentence. An attacker sniffing encrypted traffic doesn't get much information, but they do get to learn the length of messages. If they can somehow use that to learn more information about the message, maybe they can foil the encryption.

You start explaining this to Gary, and he interrupts you --- "Oh you mean like the [CRIME](https://www.nccgroup.trust/us/about-us/newsroom-and-events/blog/2012/september/details-on-the-crime-attack/) attack?"

"Yes!" you say. You start to recall the details of it -- all the SSL attacks with catchy names run together for you, but you're pretty sure it was the Where they controlled some information in that was being returned by the server, and used that to generate guesses for a secret token also in the response. The response was compressed in such a way that you could validate guesses for the secret by seeing how you affected the length of the compressed message. If the secret was `AAAA` and you guessed `AAAA`, the compressed-then-encrypted response will be shorter than if you guessed `BBBB`.

Gary looks impressed. "But what if the attacker can't control any of the plaintext in any way? Is this kind of attack still possible?" he asks.

- - -

CRIME was a very cool demonstration of how compress-then-encrypt isn't always the right decision, but my favorite compress-then-encrypt attack was published a year earlier by Andrew M. White, Austin R. Matthews, Kevin Z. Snow, and Fabian Monrose. The paper [Phonotactic Reconstruction of Encrypted VoIP Conversations](http://www.cs.unc.edu/~fabian/papers/foniks-oak11.pdf) gives a technique for reconstructing speach from an encrypted VoIP call.

Basically, the idea is this: VoIP compression isn't going to be a generic audio compression algorithm, because we can rely on some assumptions about human speach in order to compress more efficiently. From the paper:

> Many modern speech codecs are based on variants of a well-known speech coding
> scheme known as code-excited linear prediction (CELP) [49], which is in turn
> based on the source-filter model of speech prediction. The source-filter model
> separates the audio into two signals: the excitation or source signal, as
> produced by the vocal cords, and the shape or filter signal, which models the
> shaping of the sound performed by the vocal tract. This allows for
> differentiation of phonemes; for instance, vowels have a periodic excitation
> signal while fricatives (such as the [sh] and [f] sounds) have an excitation
> signal similar to white noise [53].
>
> In basic CELP, the excitation signal is modeled as an entry
> from a fixed codebook (hence code-excited). In some CELP
> variants, such as Speex’s VBR (variable bit rate) mode, the codewords can
> be chosen from different codebooks depending on the complexity
> of the input frame; each codebook contains entries
> of a different size. The filter signal is modeled using linear
> prediction, i.e., as a so-called adaptive codebook where the
> codebook entries are linear combinations of past excitation
> signals. The “best” entries from each codebook are chosen
> by searching the space of possible codewords in order
> to “perceptually” optimize the output signal in a process
> known as analysis-by-synthesis [53]. Thus an encoded frame
> consists of a fixed codebook entry and gain (coefficient) for
> the excitation signal and the linear prediction coefficients for
> the filter signal.

> Lastly, many VoIP providers (including Skype) use VBR 
> codecs to minimize bandwidth usage while maintaining
> call quality. Under VBR, the size of the codebook entry,
> and thus the size of the encoded frame, can vary based
> on the complexity of the input frame. The specification
> for Secure RTP (SRTP) [3] does not alter the size of the
> original payload; thus encoded frame sizes are preserved
> across the cryptographic layer. The size of the encrypted
> packet therefore reflects properties of the input signal; it is
> exactly this correlation that our approach leverages to model
> phonemes as sequences of lengths of encrypted packets.

That pretty much summarizes the paper. CELP + VBR means that message length is going to depend on complexity. Due to how linear prediction works, more information is needed to encode a drastic change in sound --- like the pause between phonemes! This allows the authors to build a model that can break an **encrypted** audio signal into phonemes, that is deciding which audio frames belong to which unit of speach.

They then built a classifier that, still only using the packet length information they started with, decides which actual phonemes the segmented units of encrypted audio are. They then use a language model to correct the previous step's output and segment the phoneme stream into words and then phrases.

The crazy thing is that this whole rigmarole works! They used a metric called [METEOR](http://www.cs.cmu.edu/~alavie/METEOR/) and got scores of around .6. This is on a scale where >.5 is considered "interpretable by a human." Considering that the threat vector here is a human using this technique to listen in on your encrypted VoIP calls --- that's pretty amazing! 

- - -

## Epilogue

You end up getting the job, but 6 months later, Mont Piper is sold to a large conglomerate. Gary refuses to trade in his Norwegian metal t-shirts for a button-down and is summarily fired. You now spend your days going on-site to a big bank, "advising" a team that hates your guts.

But recently, you've picked up machine learning and found this really cool online game where you try to make a 6-legged robot walk in a 3d physics simulation....
