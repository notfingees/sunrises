# sunrises
App for my startup Sunrises, which scrapes dozens of API sources to generate personalized recommendations of things and events to look forward to for users. For example, someone who likes watching American football and the Amazing Race would get recommendations for relevant upcoming football games and Amazing Race episodes, but might also get recommendations for related events such as Survivor episodes or basketball games to look forward to.

This was my first foray into software development as well as iOS development, and as a result the quality and composability of the codebase is nowhere near industry standard. That being said, I learned a lot and I'd like to think it's clear that I gained a much more thorough understanding of software engineering principles (testing, modularity, scalability) even just throughout the duration of this project.

Although it's no longer in development, you can try the app here (https://apps.apple.com/us/app/sunrises/id1583841201) or by importing the files in /Xcode into Xcode at ~/Library/Autosave Information.
In /API, you can find the API calls and SQL database design. To try them out, load them into a LAMP/MAMP-stack environment and import the database. In /scraping are most of the various Python scripts I used to scrape from data endpoints. To try them out, run pip install and generate your own API keys (if necessary). 
