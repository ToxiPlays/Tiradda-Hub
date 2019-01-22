[code]: https://github.com/CryfryDoesGaming/Tiradda-Hub
[issue]: https://github.com/CryfryDoesGaming/Tiradda-Hub/issues
[pr]: https://github.com/CryfryDoesGaming/Tiradda-Hub/pulls
[wiki]: https://github.com/CryfryDoesGaming/Tiradda-Hub/wiki
[discordia-install]: https://github.com/SinisterRectus/Discordia/wiki/Installing-Discordia
[diff]: https://github.com/CryfryDoesGaming/Tiradda-Hub/wiki/Difficulties

# Tiradda's Hub
![](https://img.shields.io/github/issues/CryfryDoesGaming/Tiradda-Hub.svg) ![](https://img.shields.io/github/forks/CryfryDoesGaming/Tiradda-Hub.svg) ![](https://img.shields.io/github/stars/CryfryDoesGaming/Tiradda-Hub.svg) ![](https://img.shields.io/github/license/CryfryDoesGaming/Tiradda-Hub.svg) ![](https://img.shields.io/badge/Made%20with-Lua-1f425f.svg) [![GitHub release](https://img.shields.io/github/release/CryfryDoesGaming/Tiradda-Hub.svg)](https://GitHub.com/CryfryDoesGaming/Tiradda-Hub/releases/)\
**Tiradda's Hub** is a game bot that will instantly set up upon inviting it to a Discord server.

## Hotlinks
[Code][code]\
[Bug Reports / Feature Requests][issue]\
[Pull Requests][pr]\
[Documentation][wiki]

> **Table of contents**
> 
> * [Tiradda's Hub](#tiraddas-hub)
>   * [Hotlinks](#hotlinks)
>   * [How to Setup](#how-to-setup)
>   * [Frequently Asked Questions (FAQ)](#frequently-asked-questions-faq)
>     - [❓ The bot won't go online!](#question-the-bot-wont-go-online)
>     - [❓ The bot suddenly won't respond to my commands! What happened?](#question-the-bot-suddenly-wont-respond-to-my-commands-what-happened)
>     - [❓ When I try to make a level, the bot responds with "That's not a vaild difficulty! See h>help for a list of vaild difficulties."](#question-when-i-try-to-make-a-level-the-bot-responds-with-thats-not-a-vaild-difficulty-see-hhelp-for-a-list-of-vaild-difficulties)
>     - [❓ All of the bot's user's levels have been erased! What happened?](#question-all-of-the-bots-users-levels-have-been-erased-what-happened)

## How to Setup
This bot runs on Discordia / Luvit and is bundled with it. If you find an error with downloading the entire code and running it via Luvit, download only the `bot.lua` file and see [Installing Discordia][discordia-install] by SinisterRectus.

## Frequently Asked Questions (FAQ)
### :question: The bot won't go online!
Look at the last line. Replace the word `TOKEN` with your app's token.
### :question: The bot suddenly won't respond to my commands! What happened?
This means that the bot crashed, and is now offline. It takes a while for Discord to display the bot as offline. Go into your terminal and start running the bot's code again.
### :question: When I try to make a level, the bot responds with "That's not a vaild difficulty! See h>help for a list of vaild difficulties."
Listen to the bot. If you're still confused, you can look at our [difficulty list][diff].
### :question: All of the bot's user's levels have been erased! What happened?
This commonly happens when the bot crashes. When you restart it, it deletes all levels regardless of if they are published or not. Unless the bot somehow never crashes on your machine, or you host it via a public source, we cannot prevent this.
