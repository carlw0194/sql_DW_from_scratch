# Silver Layer Architecture

The Silver layer contains cleansed and conformed tables. Data is typed, trimmed and lightly transformed from the raw Bronze layer.

```mermaid
flowchart TD
    A[bronze schema] -->|load_silver| B((silver tables))
    B --> C[cleansed data]
```

The `load_silver` procedure truncates each Silver table then inserts rows from Bronze, applying simple conversions and joins (e.g. ERP customer location data).
