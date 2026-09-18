# Code walkthrough

## Follow one request

Opening `/portfolios/1` reaches `PortfoliosController#show`. Active Record loads the portfolio and its holdings from PostgreSQL. `RebalancePreview` computes rows of results. The ERB template renders the HTML table. Stimulus handles the highlight threshold without another request.

Editing uses a conventional Rails form. `accepts_nested_attributes_for` lets the portfolio and its holdings be saved together. The controller permits only the expected fields. If validation fails, Rails returns HTTP 422 and the form displays errors with the entered values preserved.

## Read these files first

1. [`config/routes.rb`](../config/routes.rb): the seven standard REST actions for portfolios.
2. [`app/models/portfolio.rb`](../app/models/portfolio.rb): associations, nested attributes, and allocation-level validation.
3. [`app/models/holding.rb`](../app/models/holding.rb): symbol normalization and field-level validation.
4. [`app/controllers/portfolios_controller.rb`](../app/controllers/portfolios_controller.rb): CRUD, permitted parameters, redirects, and invalid submissions.
5. [`app/services/rebalance_preview.rb`](../app/services/rebalance_preview.rb): the calculation in a plain Ruby object.
6. [`app/javascript/controllers/allocation_controller.js`](../app/javascript/controllers/allocation_controller.js): row editing and live target totals.
7. [`test/services/rebalance_preview_test.rb`](../test/services/rebalance_preview_test.rb): examples of the calculation and its edge cases.

## Decisions to understand

**Decimal storage:** floating-point arithmetic can introduce small errors in money. PostgreSQL decimal columns preserve cents, and the allocation calculation uses rational arithmetic before assigning whole cents.

**Validation belongs on the server:** Stimulus gives immediate feedback, but requests can bypass the browser. Rails validates the complete portfolio before saving. Database constraints also reject negative values and target percentages outside 0–100.

**Calculation outside the controller:** a small service keeps the HTTP actions readable and makes the arithmetic easy to test without a browser.

**One transaction for an edit:** removing a holding and updating the remaining targets should succeed or fail together. Nested attributes and Active Record's save transaction support that behavior.

**Highlights are presentation:** a 2 pp threshold only changes which rows receive a marker. It does not remove small trades or change the target portfolio.

## Work through the rounding example

A portfolio worth $0.05 has targets of 33.33%, 33.33%, and 33.34%. Its exact target amounts are 1.6665, 1.6665, and 1.667 cents. Rounding each independently to 2 cents would create an extra cent.

The service starts with 1 cent each. It gives the first remaining cent to the third holding, then the second to the alphabetically first holding among the tied remainders. The result is 2, 1, and 2 cents: still $0.05.

## Practice explaining and changing it

- Trace a successful save and an invalid save from form to database.
- Explain `has_many`, `belongs_to`, nested attributes, strong parameters, and HTTP 422.
- Explain why an asset with 0% target is valid, while a portfolio worth $0 is not.
- Change the default drift threshold and verify its behavior in the browser.
- Add one validation or feature and a meaningful test before presenting the project as hands-on practice.

The README identifies this as AI-assisted work. Use the project to develop familiarity, and describe your own changes and what you can explain accurately.
