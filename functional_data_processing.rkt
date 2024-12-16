#lang racket

(provide (all-defined-out))
(require racket/string)

;; Data Structures
(struct sensor-data (timestamp temperature humidity air-quality noise-level) #:transparent)

;; 1. Data Input
(define (read-csv-file filename)
;; TODO: Implement CSV file reading
  ;; Handle errors in file reading
  (with-handlers ([exn:fail? (lambda (exn) (displayln (format "Error: Could not open file ~a" 
  filename)) '())]) 

    ;; Read each line and split it by commas and returning a list of list
    (cdr 
      (with-input-from-file filename
        (lambda() 
          (for/list ([line (in-lines)])
            (string-split line ","))))))
)

(define (read-all-csv-files filenames)
  ;; TODO: Implement reading multiple CSV files
  
  ;;This part of code has been update 12-15-2025
  ;; The user will write the file name only 
  (define  file-path "")
  ;;This way the user can enter the path by itself.
  
  ;; Fold over the list of filenames
  (for/fold ([all-data '()]) ([filename filenames])
    (let ([file-data (read-csv-file (string-append file-path filename))])
    ;; If file has data, display file name and first three rows to test. 
      (when (not (null? file-data))
      (displayln (format "This is file: ~a" filename))
      (for-each displayln (take file-data 3)) ;; Print the first three lines
    ;; Append file data to the data list
    (append all-data file-data))))
) 

;; 2. Data Processing
(define (clean-data data)
;; This funcation clean data by filtering and converting each row to 'sensor if it has valid enteris
  ;; TODO: Implement data cleaning
  (filter-map (lambda (row) 
    (if (= (length row) 5)  ;; Ensure row has exactly 5 elements
      (let ([timestamp (list-ref row 0)]
        [temperature (string->number (list-ref row 1))]
        [humidity (string->number (list-ref row 2))]
        [air-quality (string->number (list-ref row 3))]
        [noise-level (string->number (list-ref row 4))])
      ;; Only convert to 'sensor-data' if all values are valid numbers, except timestamp
      (if (and temperature humidity air-quality noise-level)
          (sensor-data timestamp temperature humidity air-quality noise-level)
          #f))  ;; Return false if any value is invalid
        #f)) ;; Return false if row does not have 5 elements
  data)
)

(define (round-to-two-decimals num)
    (string->number (real->decimal-string num 2)))

;;This part of code has been update 12-15-2025
(define (normalize-data data)
  ;; Helper funcation to calculate min and max values
  (define (calculate-min lst) (apply min lst))
  (define (calculate-max lst) (apply max lst))

  ;;Extract data fileds
  (define temperature (map sensor-data-temperature data))
  (define humidities (map sensor-data-humidity data))
  (define air-quality (map sensor-data-air-quality data))
  (define noise-level (map sensor-data-noise-level data))

  ;;Calculate min and max values dynamically
  (define min-temperature (calculate-min temperature))
  (define max-temperature (calculate-max temperature))
  (define min-humidity (calculate-min humidities))
  (define max-humidity (calculate-max humidities))
  (define min-air-quality (calculate-min air-quality))
  (define max-air-quality (calculate-max air-quality))
  (define min-noise-level (calculate-min noise-level))
  (define max-noise-level (calculate-max noise-level))

  ;; Normalize each data point without rounding
  (map (lambda (sd)
    (sensor-data (sensor-data-timestamp sd)
      (/ (- ( sensor-data-temperature sd) min-temperature)
        (- max-temperature min-temperature))
      (/ (- (sensor-data-humidity sd) min-humidity)
        (- max-humidity min-humidity))
      (/ (- (sensor-data-air-quality sd) min-air-quality)
        (- max-air-quality min-air-quality))
      (/ (- (sensor-data-noise-level sd) min-noise-level)
        (- max-noise-level min-noise-level))))    
      data))

;; 3. Statistical Analysis
(define (calculate-statistics data)
  ;; TODO: Implement statistical calculations

  ;; Calculate the mean of a list of numbers
  (define (calculate-mean lst)
  (/ (apply + lst) (length lst)))

  ;; Calculate the median of a list of numbers
  (define (calculate-median lst) 
    (let* ([sorted (sort lst <)]
          [n (length sorted)]
          [mid (quotient n 2)])
        (if ( odd? n)
            (list-ref sorted mid)
            (/ (+ (list-ref sorted (- mid 1)) (list-ref sorted mid)) 2))))
  
  ;;Calculate the standard deviation of the list of numbers
  (define (calculate-standard-deviation lst)
    (let ([mean (calculate-mean lst)])
      (sqrt (/ (apply + (map (lambda (x) (expt (- x mean) 2)) lst)) (length lst)))))
  
  ;; Helper functions to extract each measurment type from sensor-data
  (define (extract-temperature data) (map sensor-data-temperature data))
  (define (extract-humidity data) (map sensor-data-humidity data))
  (define (extract-air-quality data) (map sensor-data-air-quality data))
  (define (extract-noise-level data) (map sensor-data-noise-level data))
    
    (displayln "Temperature Statistics: ")
    (let ([temperature (extract-temperature data)])
      (display (format "Mean: ~a" (round-to-two-decimals(calculate-mean temperature))))
      (display (format " Median: ~a" (round-to-two-decimals(calculate-median temperature))))
      (display (format " Standard: ~a" (round-to-two-decimals(calculate-standard-deviation temperature)))))

    (displayln "\nHumidity Statistics: ")
    (let ([humidities (extract-humidity data)])
      (display (format "Mean: ~a" (round-to-two-decimals(calculate-mean humidities))))
      (display (format " Median: ~a" (round-to-two-decimals(calculate-median humidities))))
      (display (format " Standard: ~a" (round-to-two-decimals(calculate-standard-deviation humidities)))))
    
    (displayln "\nAir Quality Statistics: ")
    (let ([air-quality (extract-air-quality data)])
      (display (format "Mean: ~a" (round-to-two-decimals(calculate-mean air-quality))))
      (display (format " Median: ~a" (round-to-two-decimals(calculate-median air-quality))))
      (display (format " Standard: ~a" (round-to-two-decimals(calculate-standard-deviation air-quality)))))

    (displayln "\nNoise Level Statistics: ")
    (let ([noise-level (extract-noise-level data)])
      (display (format "Mean: ~a" (round-to-two-decimals(calculate-mean noise-level))))
      (display (format " Median: ~a" (round-to-two-decimals(calculate-median noise-level))))
      (display (format " Standard: ~a" (round-to-two-decimals(calculate-standard-deviation noise-level)))))
)

(define (analyze-time-series data)
  ;; TODO: Implement time series analysis
  ;;Sort data by timestamp
  (define sorted-data
    (sort data string<? #:key sensor-data-timestamp))

  ;; Extract timestamps and temperatrue value from the data 
  (define temperature (map sensor-data-temperature data))
  
  ;; Calculate a simple moving average
  (define (moving-average lst window-size)
    (define n (length lst))
    (if (< n window-size)
      '() ;; Return empty lis
      (cons (/ (apply + (take lst window-size)) window-size)
        (moving-average (rest lst) window-size))))

  ;; Calculate a moving average with a window size of 3
  (define temperature-trend (moving-average temperature 3))

  ;; Display the moving average trend
  (displayln "\nTemperature Moving Average Trend: ")
  (for-each displayln (take temperature-trend 5)))

;; 4. Anomaly Detection
(define (detect-anomalies data)
  ;; TODO: Use the provided anomaly detection algorithm

  ;; Calculate the mean of the data
  (define mean (/ (apply + data) (length data)))

  ;; Calculate the standard deviation
  (define std (sqrt (/ (apply + (map (lambda (x) (expt (- x mean) 2)) data)) (length data))))

  ;; Filter anomalies: data points beyond 2 standard deviations from the
  (filter (lambda (x) (> (abs (- x mean)) (* 2 std))) data))

; ;; 5. Data Correlation
; (define (calculate-correlation data1 data2)
;   ;; TODO: Implement correlation calculation
;   (let* ([mean-data1 (calculate-mean data1)]
;         [mean-data2 (calculate-mean y)]
;         [diff-data1 (map (lambda (data1i) (- xi mean-x)) datat1)]
;         [diff-data2 (map (lambda (data2i) (- yi mean-y)) data2)]
;         [numerator (apply + (map * diff-data1 diff-data2))]
;         [denominator (sqrt (* (apply + (map sqr diff-data1))
;                             (apply + (map sqr diff-data2))))])
    
;     (if (zero? denominator)
;       0
;       (/ numerator denominator))))

; ;; 6. Reporting
; (define (generate-report data statistics anomalies correlations)
;   ;; TODO: Implement report generation
;   )

;; 7. Performance Optimization
;; TODO: Implement lazy evaluation and tail recursion optimizations

;; 8. Error Handling
;; TODO: Implement error handling throughout the pipeline

;; Main function
; (define (main filenames)
;   ;; TODO: Implement the main pipeline
  
;   ;;This part to test the read-csv-file function. 
;   (define data (read-csv-file filenames))
;   (for-each displayln data)   
; )

;; ************** Run the program ( to test more than one file)

(define (main filenames)
  ;; Convert filename to a list.
  (define files-list (list filenames))
  ;; Read, clean, and normalize data from all files
  (define raw-data (read-all-csv-files files-list))
  (define cleaned-data (clean-data raw-data))
  (define sorted-data ( sort cleaned-data string<? #:key sensor-data-timestamp))
  (define normalized-data (normalize-data sorted-data))

  ;; Print first five rows of normalized data. 
  (if (null? normalized-data)
    (displayln "No data to display.")
    (begin
      (display "First five rows of normalized data:")
      (for-each displayln (take normalized-data 5))

      ;; Statistical analysis
      (calculate-statistics normalized-data)

      ;; Time series analysis
      (analyze-time-series normalized-data)
      
      ;; Anomaly detection for temperature data
      ;;(define temperature-data (map sensor-data-temperature normalized-data)) 
      ;;(define temperature-anomalies (detect-anomalies temperature-data))

      ; ;; Display temperature anomalies
      ; (displayln "\nTemperature Anomalies Detected: ")
      ; (for-each displayln temperature-anomalies)
      ))
)

;; Run the program to test one file 
(module+ main
  (command-line
   #:program "environmental-data-analyzer"
   #:args (filenames )
   (main filenames))
)
