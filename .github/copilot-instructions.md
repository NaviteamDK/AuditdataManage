# AuditdataManage — Copilot Instructions

## Project
Naviteam per-tenant BC extension integrating **AuditData Manage** (hearing care practice management) with **Microsoft Business Central**.

## App
- Publisher: Naviteam | Version: 1.0.0.0 | Platform/App: 26.0.0.0
- Object ID range: **80300–80399**
- Features: NoImplicitWith, TranslationFile
- Target: Cloud | Runtime: 15.0

## API Documentation
AuditData Manage REST API Swagger UI (V2):
https://eu-prod-manageapigateway.auditdata.app/swagger/index.html?urls.primaryName=V2

Always consult this before implementing or changing any API call.

## Architecture

```
AuditData Manage API
   │
   ├─ Clients (patients) ──► ADM Client Buffer  ──► ADM Buffer Processor ──► BC Customers
   ├─ Funders             ──► ADM Funder Buffer ──► ADM Buffer Processor ──► BC Customers
   └─ Sales               ──► ADM Sale Buffer   ──► ADM Master Order
                                                         │
                                               ADM Split Suggester
                                                         │
                                               ADM Order Splitter
                                                         │
                                               BC Sales Orders (per payer)

BC Items (Insert/Modify)
   └─ ADM Item Event Subscriber ──► Needs Sync ──► ADM Product Sync ──► AuditData Manage API
```

### Key codeunits
| Object | Purpose |
|---|---|
| `ADM API Client` (80301) | Low-level HTTP wrapper: GET/POST/PUT + paged fetch. Handles auth headers (ApiKey, EdiScheme). |
| `ADM Sync Log Manager` (80300) | Central logging: StartLog / FinishLog / FailLog |
| `ADM Split Suggester` (80303) | Generates Order Split Lines from Funder Terms |
| `ADM Order Splitter` (80304) | Converts confirmed Master Order into BC Sales Orders |
| `ADM Client Sync` (80305) | Inbound: fetches patients from `api/v1/patients/last&hours=...` |
| `ADM Funder Sync` (80306) | Inbound: fetches funders from `api/v2/invoicing/funders` |
| `ADM Sale Sync` (80307) | Inbound: fetches sales from `api/v2/invoicing/sales` |
| `ADM Product Sync` (80308) | Outbound: pushes BC Items to `api/v2/inventory/products` |
| `ADM Item Event Subscriber` (80309) | Subscribes to Item insert/modify → marks Needs Sync |
| `ADM Job Queue Manager` (80310) | Creates/manages BC Job Queue entries for all sync codeunits |
| `ADM Buffer Processor` (80302) | Processes client/funder/sale buffer records into BC master data |

### Key tables
| Object | Purpose |
|---|---|
| `ADM Integration Setup` (80300) | Singleton: API URL, key, EDI scheme, sync flags, intervals |
| `ADM Customer Mapping` (80301) | Manage GUID ↔ BC Customer No. (tagged Client or Funder) |
| `ADM Item Mapping` (80302) | BC Item No. ↔ Manage Product ID + outbound sync state |
| `ADM Sync Log` (80303) | Audit log for every sync run |
| `ADM Funder Terms` (80304) | Per-funder split rules (priority, Fixed Amount or Percentage) |
| `ADM Client Buffer` (80305) | Staging for imported patients |
| `ADM Funder Buffer` (80306) | Staging for imported funders |
| `ADM Sale Buffer Header/Line` (80307/80308) | Staging for imported sales |
| `ADM Master Order Header/Line` (80309/80310) | Promoted orders awaiting split + fulfillment |
| `ADM Order Split Line` (80311) | Per-payer split lines on a master order |

## Coding conventions
- Always thread `ErrorText` as a `var Text` parameter through `TrySync*` procedures — never use `GetLastErrorText()` for API errors.
- `GetPaged` handles top-level JSON arrays, `{data:[...]}`, `{data:{items:[...]}}`, and `{items:[...]}` responses automatically.
- BC object modifications should call `Modify()` not `ModifyAll()` unless intentionally bulk-updating.
- Use `CopyStr(..., 1, N)` when assigning `Text` API values to fixed-length fields.

## Known environment note
`ADMNavigationMenuExt.PageExt.al` may show "Navigation Menu not found" if AL symbols are not downloaded. Run `AL: Download Symbols` to resolve.
