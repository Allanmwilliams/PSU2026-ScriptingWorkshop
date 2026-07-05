# Scripting for (Not just) Beginner MacAdmins
> [!NOTE]
> Content and exercises for "Scripting for (Not Just) Beginner MacAdmins" at 2026 PSU Mac Admins conference by Adam Codega and Trevor Sysock.
>
> Ready for download! See you Tuesday.

# Hello, Attendee!

We are excited to see you on July 7th at the 2026 MacAdmins Conference in State College, PA! To help you hit the ground running, we've put together this quick checklist to get your Mac ready for our workshop.

## MacAdmins Slack

There’s a first time for everything, so if you haven’t joined the MacAdmins Slack, sign up at https://www.macadmins.org/.

The MacAdmins Slack is bigger than (and unaffiliated with) just our workshop or the conference but you’ll find it is used a lot for #psumac related things. You can find a channel for each room at the conference, including our workshop in #psumac-deans-1.

## The Essentials

For the workshop, you’ll need a Mac with a few apps pre-installed. We will require a Mac with macOS 15 or macOS 26, because macOS ships with `jq` in macOS 15 and later. (`jq` is one of the built-in binaries you’ll learn about during the workshop)

## Do I need a spare Mac?

You don't need a spare Mac, but we recommend bringing one you feel comfortable using for testing. While we won't do anything intentionally destructive, accidents happen! If you bring your work Mac, just double-check that your MDM or security tools won't block you from running scripts locally.

Using a Virtual Machine (VM) is totally fine, provided you are comfortable managing it yourself and troubleshooting doesn't slow you down.

Unlike an MDM workshop, you won’t necessarily be doing the script writing on one Mac, and executing the script on another. You’ll be taking notes, writing scripts, and demoing scripts on the same Mac.

## Our prepared resources

When it is available, download this workshop repo by clicking the green **Code** button then select **Download ZIP**.

Do not download the repo until you see it’s labeled at the top of this message. (At the latest, it will be ready the night before the workshop)

# Apps to Install

## Microsoft Visual Studio Code

https://code.visualstudio.com/

VSC is the text editor we will be teaching from. You can choose to use a different text editor as long as you can troubleshoot for yourself. In the absence of a preferred editor, use VSC. We will cover only a few extensions, so we do not recommend installing a bunch or spending time customizing anything before the workshop.

## VSC Extensions

To install extensions, check out Microsoft’s instructions at: https://code.visualstudio.com/docs/configure/extensions/extensions

When you search the Extension Marketplace, check that you have the correct extension by verifying the publisher name:

- **EditorConfig** from the publisher **"EditorConfig"**
- **ShellCheck** from the publisher **"Timon Wong"**

## GitHub Desktop (Optional)

https://desktop.github.com/download/

We’ll go over some Git and GitHub basics in the latter half of the workshop. Install GitHub Desktop on your Mac, and sign up for a free GitHub account if you don’t already have one. Then, go to the GitHub Desktop app’s settings window and “Sign into GitHub.com”.

## Git (Optional)

Git (the command line utility) can be installed by installing Xcode Command-line Tools. These are separate from the Xcode Desktop app and do not require Xcode to be installed nor does it require an Apple Account.

On your Mac, open Terminal and run:

```bash
xcode-select --install
```

In the system dialog that appears, click **Install** and then agree to the Command Line Tools License Agreement. After the installation finishes, click **Done**.

# Additional Downloads

We’ll be using a few popular MacAdmin utilities to show how you can use them in your scripts for more advanced automation. Grab these pkgs, we will install them as part of our exercises if they’re not already installed.

## SwiftDialog

https://github.com/swiftDialog/swiftDialog

Download the SwiftDialog pkg ahead of time. On GitHub, you’ll find it on the right side of the page under Releases. Download version 3.0.1.

## Dockutil

https://github.com/kcrawford/dockutil

Download version 3.1.3.
