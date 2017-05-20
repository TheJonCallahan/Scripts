REM sets CS battery saver time-out to four hours:
powercfg /setdcvalueindex SCHEME_CURRENT e73a048d-bf27-4f12-9731-8b2076e8891f 7398e821-3937-4469-b07b-33eb785aaca1 14400
powercfg /setacvalueindex SCHEME_CURRENT e73a048d-bf27-4f12-9731-8b2076e8891f 7398e821-3937-4469-b07b-33eb785aaca1 14400

REM sets CS battery saver trip point to 100:
powercfg /setdcvalueindex SCHEME_CURRENT e73a048d-bf27-4f12-9731-8b2076e8891f 1e133d45-a325-48da-8769-14ae6dc1170b 100
powercfg /setacvalueindex SCHEME_CURRENT e73a048d-bf27-4f12-9731-8b2076e8891f 1e133d45-a325-48da-8769-14ae6dc1170b 100

REM sets the CS battery saver action to hibernate:
powercfg /setdcvalueindex SCHEME_CURRENT e73a048d-bf27-4f12-9731-8b2076e8891f c10ce532-2eb1-4b3c-b3fe-374623cdcf07 001
powercfg /setacvalueindex SCHEME_CURRENT e73a048d-bf27-4f12-9731-8b2076e8891f c10ce532-2eb1-4b3c-b3fe-374623cdcf07 001

powercfg /setactive SCHEME_CURRENT