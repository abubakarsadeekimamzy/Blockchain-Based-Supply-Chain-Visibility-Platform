;; Product Registration Contract
;; Records item details

(define-map products
  { product-id: (string-ascii 36) }
  {
    name: (string-ascii 100),
    description: (string-utf8 500),
    manufacturer: (string-ascii 36), ;; entity-id of manufacturer
    sku: (string-ascii 50),
    batch-number: (string-ascii 50),
    manufacturing-date: uint,
    expiry-date: (optional uint),
    registered-by: principal,
    registered-at: uint
  }
)

(define-read-only (get-product (product-id (string-ascii 36)))
  (map-get? products { product-id: product-id })
)

(define-public (register-product
    (product-id (string-ascii 36))
    (name (string-ascii 100))
    (description (string-utf8 500))
    (manufacturer (string-ascii 36))
    (sku (string-ascii 50))
    (batch-number (string-ascii 50))
    (manufacturing-date uint)
    (expiry-date (optional uint))
  )
  (let ((product-exists (is-some (get-product product-id))))
    (asserts! (not product-exists) (err u1)) ;; Error if product already exists
    (ok (map-set products
      { product-id: product-id }
      {
        name: name,
        description: description,
        manufacturer: manufacturer,
        sku: sku,
        batch-number: batch-number,
        manufacturing-date: manufacturing-date,
        expiry-date: expiry-date,
        registered-by: tx-sender,
        registered-at: block-height
      }
    ))
  )
)

(define-public (update-product-details
    (product-id (string-ascii 36))
    (name (string-ascii 100))
    (description (string-utf8 500))
  )
  (let ((product (get-product product-id)))
    (asserts! (is-some product) (err u2)) ;; Error if product doesn't exist
    (asserts! (is-eq tx-sender (get registered-by (unwrap-panic product))) (err u3)) ;; Only registered-by can update
    (ok (map-set products
      { product-id: product-id }
      (merge (unwrap-panic product)
        {
          name: name,
          description: description
        }
      )
    ))
  )
)
