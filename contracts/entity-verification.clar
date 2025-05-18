;; Entity Verification Contract
;; Validates supply chain participants

(define-data-var admin principal tx-sender)

;; Entity types: 1=Manufacturer, 2=Distributor, 3=Retailer, 4=Logistics
(define-map entities
  { entity-id: (string-ascii 36) }
  {
    name: (string-ascii 100),
    entity-type: uint,
    address: (string-ascii 100),
    verified: bool,
    created-at: uint
  }
)

(define-read-only (get-entity (entity-id (string-ascii 36)))
  (map-get? entities { entity-id: entity-id })
)

(define-public (register-entity
    (entity-id (string-ascii 36))
    (name (string-ascii 100))
    (entity-type uint)
    (address (string-ascii 100))
  )
  (let ((entity-exists (is-some (get-entity entity-id))))
    (asserts! (not entity-exists) (err u1)) ;; Error if entity already exists
    (ok (map-set entities
      { entity-id: entity-id }
      {
        name: name,
        entity-type: entity-type,
        address: address,
        verified: false,
        created-at: block-height
      }
    ))
  )
)

(define-public (verify-entity (entity-id (string-ascii 36)))
  (let ((entity (get-entity entity-id)))
    (asserts! (is-some entity) (err u2)) ;; Error if entity doesn't exist
    (asserts! (is-eq tx-sender (var-get admin)) (err u3)) ;; Only admin can verify
    (ok (map-set entities
      { entity-id: entity-id }
      (merge (unwrap-panic entity) { verified: true })
    ))
  )
)

(define-public (update-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u3)) ;; Only current admin can update
    (ok (var-set admin new-admin))
  )
)
