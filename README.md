## About

Markdown Viewer is a simple application for viewing Markdown files. There is also the possibility to export Markdown files to other formats. Markdown Viewer also privides a QuickLook plugin.

Markdown Viewer requires Mac OS 10.8 or later.

## Localizations

Currently, Markdown Viewer has an English and German localization.

### Adding Localizations

If you wish to add localization yourself, read the following sections.

If you have never localized strings files before, read the the "Localizing Strings Files" chapter of Apples [Notes for Localizers](https://developer.apple.com/library/mac/#documentation/MacOSX/Conceptual/BPInternational/Articles/NotesForLocalizers.html#//apple_ref/doc/uid/20000044-SW1) documentation.

#### Adding a new localization from Xcode

The easiest way to create a new localization is to fork the Markdown Viewer project and to create a new localization from Xcode. This way, I can merge your changes back into my repository :).

#### If you don't have Xcode

1. Download the `template.lproj.zip` file from the downloads.
2. Translate the strings files as specified in the "Localizing Strings Files" chapter linked to above.
3. Rename `template.lproj` to match your language code. For information what your language code should be, read [Apples documentation on language designators](https://developer.apple.com/library/mac/#documentation/MacOSX/Conceptual/BPInternational/Articles/LanguageDesignations.html).
3. Send your translation to me via email (you can find it on my github profile).
