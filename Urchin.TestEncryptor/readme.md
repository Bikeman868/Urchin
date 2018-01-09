# Sample encryptor plug-in

This project shows how to write a custom encryption plug-in for Urchin.

If you compile this project and copy the assembly into the `bin` folder
of the Urchin server, then the server will use the TestEncryptor class
in this project to encrypt all configuration data that is sent to
applications to configure them.