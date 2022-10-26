import 'package:flutter/widgets.dart';

import '../i18n/i18n.dart';

final releaseNotes = [
  ReleaseNote(
    buildNumber: 88,
    date: DateTime(2022, 10, 26),
    releaseNote: '''
📹 Rename Space to TubeCards
📖 Make TubeCards open source
    ''',
    version: '2.1.0',
    whatsNewText: (context) => S.of(context).whatsNew88Text,
  ),
  ReleaseNote(
    buildNumber: 86,
    date: DateTime(2022, 9, 16),
    releaseNote: '''
🖼️ Add ability to paste images into the editor
    ''',
    version: '2.0.6',
  ),
  ReleaseNote(
    buildNumber: 85,
    date: DateTime(2022, 7, 15),
    releaseNote: '''
🇯🇵 Fix import errors of cloze flashcards from Anki
    ''',
    version: '2.0.4',
  ),
  ReleaseNote(
    buildNumber: 84,
    date: DateTime(2022, 7, 5),
    releaseNote: '''
🤌 Improve italian translation
🚧 Update website to easier join shared decks
    ''',
    version: '2.0.4',
  ),
  ReleaseNote(
    buildNumber: 84,
    date: DateTime(2022, 4, 27),
    releaseNote: '''
🤌 Improve italian translation
🚧 Update website to easier join shared decks
    ''',
    version: '2.0.1',
  ),
  ReleaseNote(
    buildNumber: 81,
    date: DateTime(2022, 4, 11),
    releaseNote: '''
✨ Simplify UI by removing strength and stability
🐞 Fix bug when publishing decks
    ''',
    version: '2.0.1',
  ),
  ReleaseNote(
    buildNumber: 79,
    date: DateTime(2022, 1, 10),
    releaseNote: '''
🏪 Download public decks
📐 Add shapes to your images
    ''',
    version: '2.0.0',
    whatsNewText: (context) => S.of(context).whatsNew79Text,
  ),
  ReleaseNote(
    buildNumber: 78,
    date: DateTime(2021, 12, 14),
    releaseNote: '''
🎧 Listen to your flashcards while you learn them
🚅 Improve performance on Windows
📏 Fix bugs that occurred during drawing images
🗒️ Make flashcards easier to flip while learning
    ''',
    version: '1.10.0',
    whatsNewText: (context) => S.of(context).whatsNew78Text,
  ),
  ReleaseNote(
    buildNumber: 72,
    date: DateTime(2021, 11, 18),
    releaseNote: '''
✉️ Export to CSV
😊 Improved spaced repetition algorithm
🌇 Add text to your images
🤟 Improved Portuguese translation
    ''',
    version: '1.9.0',
    whatsNewText: (context) => S.of(context).whatsNew72Text,
  ),
  ReleaseNote(
    buildNumber: 70,
    date: DateTime(2021, 11, 9),
    releaseNote: '''
🐛 Fix errors during csv import
    ''',
    version: '1.8.2',
  ),
  ReleaseNote(
    buildNumber: 69,
    date: DateTime(2021, 11, 8),
    releaseNote: '''
✨ Improve explanation of strength and stability
    ''',
    version: '1.8.1',
  ),
  ReleaseNote(
    buildNumber: 68,
    date: DateTime(2021, 11, 7),
    releaseNote: '''
💪 Add strength and stability
📏 Add dividers to the editor
🏎️ Add shortcuts on all pages in the desktop version
    ''',
    version: '1.8.0',
    whatsNewText: (context) => S.of(context).whatsNew68Text,
  ),
  ReleaseNote(
    buildNumber: 67,
    date: DateTime(2021, 10, 12),
    releaseNote: '''
🎬 Reset the scroll position of cards to the top when learning
🔄 Show refresh icon on desktop
🔗 Fix bug that prevents connecting to the server on Android devices <= 7
    ''',
    version: '1.7.0',
  ),
  ReleaseNote(
    buildNumber: 66,
    date: DateTime(2021, 9, 10),
    releaseNote: '''
💬 Improve error message when CSV import fails
🪲 Fix bug during import
    ''',
    version: '1.6.2',
  ),
  ReleaseNote(
    buildNumber: 65,
    date: DateTime(2021, 9, 7),
    releaseNote: '''
📖 Add deck descriptions
🇮🇹 Improve italian translation (thanks A. Lombardo)
💅 Improve design details of the decks
🐛 Fix pick file bug when importing an Anki file
🐜 Fix bugs regarding the due cards on the home page
    ''',
    version: '1.6.1',
  ),
  ReleaseNote(
    buildNumber: 64,
    date: DateTime(2021, 8, 23),
    releaseNote: '''
🛏️ Make decks deactivatable
🧮 Add small statistics
🗳️ Add possibility to vote for the next features
🦗 Fix import for iOS
🐧 Add import and image support for Linux
💨 Add editor shortcuts for Windows, macOS and Linux
    ''',
    version: '1.6.0',
  ),
  ReleaseNote(
    buildNumber: 63,
    date: DateTime(2021, 7, 27),
    releaseNote: '''
🔥 Add CSV import
🤝 Accept deck invitations directly on desktop
🐜 Fix bug that prevented adding images on the back side
🐛 Fix import bugs for Windows and Linux
    ''',
    version: '1.5.1',
  ),
  ReleaseNote(
    buildNumber: 62,
    date: DateTime(2021, 7, 17),
    releaseNote: '''
🐧 Add Linux version
🚅 Speed up search
💇 Redesign "About TubeCards" page
🦚 Redesign "Support TubeCards" page
💅 Redesign "Feedback" page
🏆 Adjust congratulation page for large screens
👁️ Show markdown in card item preview
🖼️ Improve design of the deck cover image
🔎 Use svg for better image resolution
⌛ Improve remaining time calculation during import
🕰️ Fix reminder crash on Android
    ''',
    version: '1.5.0',
  ),
  ReleaseNote(
    buildNumber: 61,
    date: DateTime(2021, 7, 4),
    releaseNote: '🧘 Add Anki import',
    version: '1.4.0',
  ),
  ReleaseNote(
    buildNumber: 60,
    date: DateTime(2021, 6, 12),
    releaseNote: '''
🪟 Add Windows version
🍎 Add macOS version
🔍 Use higher resolution during image search for large devices
    ''',
    version: '1.3.0',
    whatsNewText: (context) => S.of(context).whatsNew60Text,
  ),
  ReleaseNote(
    buildNumber: 59,
    date: DateTime(2021, 6),
    releaseNote: '''
🦺 Add more safe areas for notches
✨ Use shimmer effect for loading cards buttons
🔥 Remove flicker when transition to some pages
📊 Increase toolbar height in editor
''',
    version: '1.2.7',
  ),
  ReleaseNote(
    buildNumber: 58,
    date: DateTime(2021, 5, 28),
    releaseNote: '''
🚄 Improve app performance
🦗 Fix logout bug when deleting something
''',
    version: '1.2.6',
  ),
  ReleaseNote(
    buildNumber: 57,
    date: DateTime(2021, 5, 27),
    releaseNote: '''
🚅 Improve app performance
🎨 Add option to edit images
''',
    version: '1.2.5',
  ),
  ReleaseNote(
    buildNumber: 55,
    date: DateTime(2021, 5, 8),
    releaseNote: '''
😰 Return to the previous version for now, as there was a memory leak in the latest version which takes longer than expected to fix.
''',
    version: '1.1.2-2',
  ),
  ReleaseNote(
    buildNumber: 54,
    date: DateTime(2021, 4, 29),
    releaseNote: '''
💨 Speed up app
👶 Reset your password directly from the app
''',
    version: '1.2.3',
  ),
  ReleaseNote(
    buildNumber: 53,
    date: DateTime(2021, 4, 28),
    releaseNote: '',
    version: '1.2.2',
  ),
  ReleaseNote(
    buildNumber: 51,
    date: DateTime(2021, 4, 15),
    releaseNote: '''
⛷️ Improve scroll performance on the deck page
🐌 Remove lag when navigating to the deck page
🤍 Redo the editor (there may still be bugs)
  - Make it easier to select text
  - Adjust style of the code block
🌚 Add option that the theme adapts to the operation system
🐞 Fix layout bugs on login and sign up page for tablets
''',
    version: '1.2.0',
  ),
  ReleaseNote(
    buildNumber: 50,
    date: DateTime(2021, 3, 18),
    releaseNote: '',
    version: '1.1.2',
  ),
  ReleaseNote(
    buildNumber: 49,
    date: DateTime(2021, 3, 11),
    releaseNote: '''
👪 Add option to change member role
🚶 Add option to remove users from deck
🦗 Show correct error message when log in failed
''',
    version: '1.1.1',
  ),
  ReleaseNote(
    buildNumber: 48,
    date: DateTime(2021, 3, 7),
    releaseNote: '''
🤝 Add deck sharing option
''',
    version: '1.1.0',
  ),
  ReleaseNote(
    buildNumber: 47,
    date: DateTime(2021, 1, 26),
    releaseNote: '''
📹 Add possibility to add gifs on cards
🐛 Fix bug when uploading multiple images
🪲 Fix bug when deleting a deck
🦟 Fix image bug for Android 10+
''',
    version: '1.0.11',
  ),
  ReleaseNote(
    buildNumber: 46,
    date: DateTime(2021, 1, 22),
    releaseNote: '''
⏰ Readd reminder system based only on time
📊 Readd sort option on deck page
🖤 Fix black screen bug on the preference page
🧍 Show loading indicator when moving cards
🧍‍♂️ Show loading indicator on login/"sign up"/"Get started" longer until the page transition
💦 Show the splash screen earlier instead of a black screen
🔍 Add zoom animation for double tap on interactive image
🐜 Fix bug when clicking multiple times on "Get started"
''',
    version: '1.0.10',
  ),
  ReleaseNote(
    buildNumber: 45,
    date: DateTime(2021, 1, 13),
    releaseNote: '',
    version: '1.0.9',
  ),
  ReleaseNote(
    buildNumber: 44,
    date: DateTime(2021, 1, 11),
    releaseNote: '''
🖼️ Handle image files correct that contain unsafe characters, e.g. whitespace
🔍 Allow to zoom svg images during review
👏 Improve "Support us" experience
''',
    version: '1.0.8',
  ),
  ReleaseNote(
    buildNumber: 43,
    date: DateTime(2021, 1, 6),
    releaseNote: '''
🕹️ Update review controls
  - More screen estate for the label buttons to emphasize and make it easier to press
  - An indication when dragging the card that it will be labeled
😧 Show error message for unsaved repetitions
🖲️ Add haptic feedback on cards and decks
''',
    version: '1.0.7',
  ),
  ReleaseNote(
    buildNumber: 41,
    date: DateTime(2021),
    releaseNote: '''
🍎 Add iOS version to App Store
🧍 Show loading indicator on the deck page
💸 Add donation option
''',
    version: '1.0.5',
  ),
  ReleaseNote(
    buildNumber: 40,
    date: DateTime(2020, 12, 26),
    releaseNote: '',
    version: '1.0.4',
  ),
  ReleaseNote(
    buildNumber: 39,
    date: DateTime(2020, 12, 25),
    releaseNote: '',
    version: '1.0.3',
  ),
  ReleaseNote(
    buildNumber: 38,
    date: DateTime(2020, 12, 24),
    releaseNote: '',
    version: '1.0.2',
  ),
  ReleaseNote(
    buildNumber: 36,
    date: DateTime(2020, 12, 23),
    releaseNote: '',
    version: '1.0.1',
  ),
  ReleaseNote(
    buildNumber: 35,
    date: DateTime(2020, 12, 21),
    releaseNote: '''
📐 Overhaul architecture, everything is faster now.
🚄 There are now the languages: Swedish, Chinese, Polish and Russian.
🌤️ Many smaller features.
''',
    version: '1.0.0',
  ),
  ReleaseNote(
    buildNumber: 27,
    date: DateTime(2020),
    releaseNote: '',
    version: '0.17.0',
  ),
  ReleaseNote(
    buildNumber: 25,
    date: DateTime(2019, 11, 30),
    releaseNote: '',
    version: '0.16.3',
  ),
  ReleaseNote(
    buildNumber: 24,
    date: DateTime(2019, 11, 30),
    releaseNote: '',
    version: '0.16.2',
  ),
  ReleaseNote(
    buildNumber: 23,
    date: DateTime(2019, 11, 17),
    releaseNote: '''
🖋️ Style your cards now in italic and bold
🦟 Remove bug that sneaked in with the last version
''',
    version: '0.16.1',
  ),
  ReleaseNote(
    buildNumber: 22,
    date: DateTime(2019, 11, 13),
    releaseNote: '''
📋 Share text and images with TubeCards to create cards more easily
🇮🇹 Use TubeCards in Italian
🐛 Have no problems with missing images
''',
    version: '0.16.0',
  ),
  ReleaseNote(
    buildNumber: 21,
    date: DateTime(2019, 10, 6),
    releaseNote: '''
🃏 Limit the number of new cards per day
🎉 Finally no white screen when opening the app, instead a black screen
''',
    version: '0.15.0',
  ),
  ReleaseNote(
    buildNumber: 20,
    date: DateTime(2019, 9, 20),
    releaseNote: '''
🗺️ Translation for Portuguese
🐞 Remove scroll bug when adding cards
''',
    version: '0.14.0',
  ),
  ReleaseNote(
    buildNumber: 19,
    date: DateTime(2019, 9),
    releaseNote: '''
🗺️ Translations for German, French, Turkish
➡️ Fix and improve 'Move to deck' functionality
📦 Import and export your TubeCards decks (more to come!)
''',
    version: '0.13.0',
  ),
  ReleaseNote(
    buildNumber: 18,
    date: DateTime(2019, 8, 18),
    releaseNote: '''
💬 Get smart translations when creating cards.
🔄 Create cards and learn them in both directions.
''',
    version: '0.12.0',
  ),
  ReleaseNote(
    buildNumber: 17,
    date: DateTime(2019, 8, 17),
    releaseNote: '''
📜 You can now scroll your cards when you learn.
''',
    version: '0.11.0',
  ),
  ReleaseNote(
    buildNumber: 14,
    date: DateTime(2019, 7, 29),
    releaseNote: '''
✍️ Create drawings for your cards
''',
    version: '0.10.0',
  ),
  ReleaseNote(
    buildNumber: 13,
    date: DateTime(2019, 7, 16),
    releaseNote: '''
🖼️ Design improvements and fixes all over the place
↪️ Ability to move cards between decks
📊 Sort cards: Alphabetically, by due date or by creation date
🔎 Search through cards directly in a deck
💬 In-App feedback form. We'd love to hear your thoughts and ideas!
''',
    version: '0.9.0',
  ),
  ReleaseNote(
    buildNumber: 12,
    date: DateTime(2019, 6, 26),
    releaseNote: '''
🦟 Fix crashes with reminders
🏳️ Transparent images now have a white background
🏃‍♂️ Create cards faster
''',
    version: '0.8.1',
  ),
  ReleaseNote(
    buildNumber: 11,
    date: DateTime(2019, 6, 22),
    releaseNote: '''
🖼 Use images to make your flashcards even more expressive.
😎 Edit your flashcards as you learn to improve them or correct typos instantly.
''',
    version: '0.8.0',
  ),
  ReleaseNote(
    buildNumber: 10,
    date: DateTime(2019, 5, 6),
    releaseNote: '''
📝 New, powerful card editor featuring lists, quotes and code snippets. We are on a mission to support all the things!
🎊 Congratulations now happen with the support of a smooth animation so you'll be even happier after you learned your cards.
''',
    version: '0.7.0',
  ),
  ReleaseNote(
    buildNumber: 9,
    date: DateTime(2019, 4, 5),
    releaseNote: '''
🔧 Added option to set the maximum number of cards per learn session.
''',
    version: '0.6.1',
  ),
  ReleaseNote(
    buildNumber: 8,
    date: DateTime(2019, 3, 23),
    releaseNote: '''
🎉 We will congratulate you and show some statistics after you learned. Because we like you.
😍 Substantially simplified creation of reminders. Should be easy as pie now.
💪 Introducing smaller sessions to keep you motivated.
''',
    version: '0.6.0',
  ),
  ReleaseNote(
    buildNumber: 7,
    date: DateTime(2019, 2, 24),
    releaseNote: '''
⏰ Extensive reminder support
📝 Greatly improved data handling
💅 Simplified deck screen design
''',
    version: '0.5.0',
  ),
  ReleaseNote(
    buildNumber: 6,
    date: DateTime(2019, 2, 4),
    releaseNote: '''
👋 Use TubeCards without an account
🔍 Search your decks and cards
💅 Fresh new logo
''',
    version: '0.4.0',
  ),
  ReleaseNote(
    buildNumber: 5,
    date: DateTime(2019, 1, 21),
    releaseNote: '''
🤯 Increased funness (is that even a word?) and intuitiveness of learn screen
🖌️ Redesigned deck screen
🌞 Ability to always learn deck cards independent of the SRS algorithm
🐞 Couple of bug fixes
''',
    version: '0.3.0',
  ),
  ReleaseNote(
    buildNumber: 4,
    date: DateTime(2019, 1, 17),
    releaseNote: '''
🗺️ Simplified bottom navigation
🐛 Fixed some minor bugs
''',
    version: '0.2.1',
  ),
  ReleaseNote(
    buildNumber: 3,
    date: DateTime(2021, 1, 15),
    releaseNote: '''
📺 Major overhaul of the interface
🔑 In-app sign up functionality
👩 Profile screen with preferences
''',
    version: '0.2.0',
  ),
  ReleaseNote(
    buildNumber: 2,
    date: DateTime(2018, 12, 21),
    releaseNote: '''
🖼️ Your decks now include images
📅 Learn today's cards functionality
⛺ Partial offline support
''',
    version: '0.1.0',
  ),
  ReleaseNote(
    buildNumber: 1,
    date: DateTime(2018, 9, 18),
    releaseNote: '''
👋 Hello world!
''',
    version: '0.0.1',
  ),
];

class ReleaseNote {
  const ReleaseNote({
    required this.buildNumber,
    required this.version,
    required this.date,
    required this.releaseNote,
    this.whatsNewText,
  });

  final int buildNumber;
  final String version;
  final LocalizedText? whatsNewText;
  final DateTime date;
  final String releaseNote;
}

typedef LocalizedText = String Function(BuildContext context);
