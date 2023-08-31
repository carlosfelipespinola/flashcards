# Download  
https://play.google.com/store/apps/details?id=dev.carlosfelipe.flashcards

# Getting Started

run ```flutter packages get``` to install the required packages  

run ```flutter gen-l10n``` to generate internationalization files  

run ```flutter run lib/main.dart``` to start the application  


# Technologies
  Flutter: 2.10.x  
  JDK: 17

# Architecture  


### Layers and dependencies  
/ domain - defines the business logic of the application.  
/ data - contains everything related to data access.  
/ ui - contains everything related to user interface.  
/ services - contains services that communicates directly with the platform.  

![packge diagram](docs/package_diagram.svg "Package diagram")  
![classes dependencies](docs/classes_dependencies.svg "Classes dependencies")  