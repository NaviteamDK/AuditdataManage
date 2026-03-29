# AuditdataManage

Business Central extension for bidirectional integration with [AuditData Manage](https://www.auditdata.com/) — a hearing care practice management system.

## Overview

| Direction | Data |
|---|---|
| BC → Manage | Items (Products) |
| Manage → BC | Clients (Customers), Funders (Customers), Sales (Orders) |

Sales imported from Manage are staged in buffer tables and processed into a Master Order, which is then split into individual BC Sales Orders per funder/client payment terms.

## Workspace Structure

```
AuditdataManage/
├── AuditdataManage.code-workspace   ← Open this in VS Code
├── app/                             ← Main extension (ID range 50100–50199)
│   ├── app.json
│   └── src/
└── test/                            ← Test app (ID range 50200–50299)
    ├── app.json
    └── src/
```

## Requirements

- Microsoft Business Central 26.0 (2025 Wave 1)
- AL Language extension for VS Code
- AuditData Manage API key

## Getting Started

1. Clone the repository
2. Open `AuditdataManage.code-workspace` in VS Code
3. Run `AL: Download Symbols` in both the `app` and `test` folders
4. Configure API credentials in **ADM Integration Setup** after deploying

## Publisher

Naviteam
