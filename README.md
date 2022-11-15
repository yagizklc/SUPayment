# SUPayment
Blockchain based payment project to be used within Sabancı University

Sub-projects constituting SUPayment:

1. SUCoin: Stable-Coin pegged to Turkish Lira. Planned to be implemented off-line, where University will mint manually as they recieve TL through off-chain methods.

2. PosDevice: Physical Pos machine-like device powered by Ardunio Nano. Main purpose is to print out QR code's with embedded URL links to Metamask, thereby allows users to approve payments with one click.

3. Mobile App: As the last step of the project, we plan to build a mobile app interface connected to Metamask to easily manage and track assets. Furthermore, as new projects and features are developed, they will be added to the app's interface.

## RoadMap
Our roadmap for the term of Fall 2022 is to complete these subprojects as much as possible. Under the supervision of Sabanci University Academics Kamer Kaya, Hüsnü Yenigün and Erkay Savaş, we aim to bring the project to a place where it can be used by facilities and business within the university as well as by third-party projects.

### What we have done (As of week 6):
- Aggregating and putting together the code and documentation done by teams preceeding us.
- Planned 3 Layer2 solutions for Scaling (see docs folder for further detail)
- Planned an off-line minting mechanism for SUCoin. Still looking for better solutions.


### What are we doing:
- Reading Layer2 solutions, then we will deploy smart contracts for swapping to each of their testnets, analyze and compare results and pick one to be used for the remainder of the project.
- Testing the PosDevice's QR generation. Looking for a way to add addresses dynamically rather than hardcoding them.
- Building a simple prototype for mobile interface with 'Connect Wallet' feature.
