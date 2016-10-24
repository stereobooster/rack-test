package main

import (
    "log"
    "net/http"
    "encoding/json"
    "io"
    "io/ioutil"
)

type BlaResponse1 struct {
    Results []int
}

type BlaRequest struct {
    Name string
}

func main() {
    http.HandleFunc("/bla", func(w http.ResponseWriter, r *http.Request) {
        switch r.Method {
        case "GET":
            w.Header().Set("Content-Type", "application/json")
            w.WriteHeader(http.StatusOK)
            response := BlaResponse1{
              Results: []int{1, 2, 3},
            }
            json.NewEncoder(w).Encode(response)
        case "POST":
            var request BlaRequest
            body, err := ioutil.ReadAll(io.LimitReader(r.Body, 1048576))
            if err != nil {
               panic(err)
            }
            if err := r.Body.Close(); err != nil {
               panic(err)
            }
            if err := json.Unmarshal(body, &request); err != nil {
               w.Header().Set("Content-Type", "application/json; charset=UTF-8")
               w.WriteHeader(422) // unprocessable entity
               if err := json.NewEncoder(w).Encode(err); err != nil {
                   panic(err)
               }
            }

            w.Header().Set("Content-Type", "application/json")
            w.WriteHeader(http.StatusOK)
            if err := json.NewEncoder(w).Encode(request); err != nil {
               panic(err)
            }
        default:
            w.WriteHeader(400) // unprocessable entity
        }
    })

    log.Fatal(http.ListenAndServe(":3000", nil))

    log.Print("Starting server")
}
