#include <iostream>
#include <string>
#include <vector>

using namespace std;

struct Restaurant {
    int id;
    string name;
    string cuisine;
    string borough;
};

vector<Restaurant> restaurants;

void showMenu() {
    cout << "==============================\n";
    cout << "   NYC Restaurant Finder - Prototype   \n";
    cout << "==============================\n";
    cout << "1) Show sample restaurants\n";
    cout << "2) About this project\n";
    cout << "3) Create restaurant\n";
    cout << "4) Read restaurant\n";
    cout << "5) Update restaurant\n";
    cout << "6) Delete restaurant\n";
    cout << "7) Filter restaurants\n";
    cout << "0) Exit\n";
    cout << "Choose an option: ";
}

void showSampleRestaurants() {
    vector<Restaurant> sample = {
        {1, "Thai Villa", "Thai", "Manhattan"},
        {2, "Prince Street Pizza", "Italian", "Manhattan"},
        {3, "Tacos El Bronco", "Mexican", "Brooklyn"}
    };

    cout << "\nSample Restaurant Results:\n";
    for (auto &r : sample) {
        cout << " - " << r.name
                  << " | " << r.cuisine
                  << " | " << r.borough << "\n";
    }
    cout << "\n";
}

void showAbout() {
    cout << "\nNYC Restuarant Finder is a restaurant finder app \n"
              << "that integrates NYC health inspections, \n"
              << "Open Restaurants compliance, and 311 complaint data.\n\n";
}

void createRestaurant() {
    Restaurant r;

    cout << "Enter ID: ";
    cin >> r.id;
    cin.ignore();

    cout << "Enter name: ";
    getline(cin, r.name);

    cout << "Enter cuisine: ";
    getline(cin, r.cuisine);

    cout << "Enter borough: ";
    getline(cin, r.borough);

    restaurants.push_back(r);

    cout << "Restaurant added!\n\n";
}

void readRestaurant() {
   cout << "\n--- Restaurants ---\n";
    for (const auto& r : restaurants) {
       cout << r.id << " | " << r.name
                  << " | " << r.cuisine
                  << " | " << r.borough << "\n";
    }
   cout << "\n";
}


void updateRestaurant() {
    int id;
   cout << "Enter ID to update: ";
   cin >> id;
   cin.ignore();

    for (auto& r : restaurants) {
        if (r.id == id) {
           cout << "New name: ";
           getline(std::cin, r.name);

           cout << "New cuisine: ";
           getline(std::cin, r.cuisine);

           cout << "New borough: ";
           getline(std::cin, r.borough);

           cout << "Updated!\n\n";
            return;
        }
    }
   cout << "Not found.\n\n";
}


void deleteRestaurant() {
    int id;
   cout << "Enter ID to delete: ";
   cin >> id;

    for (int i = 0; i < restaurants.size(); i++) {
        if (restaurants[i].id == id) {
            restaurants.erase(restaurants.begin() + i);
           cout << "Deleted!\n\n";
            return;
        }
    }
   cout << "Not found.\n\n";
}


void filterRestaurants() {
   string type;
   cout << "Enter cuisine to filter: ";
   cin >> type;

   cout << "\nMatches:\n";
    for (const auto& r : restaurants) {
        if (r.cuisine == type) {
           cout << r.id << " | " << r.name
                      << " | " << r.cuisine
                      << " | " << r.borough << "\n";
        }
    }
   cout << "\n";
}



int main() {
    while (true) {
        showMenu();
        string choice;
        getline(cin, choice);

        if (choice == "1") {
            showSampleRestaurants();
        } else if (choice == "2") {
            showAbout();
        } else if (choice == "3") {
            createRestaurant();
        } else if (choice == "4") {
            readRestaurant();
        } else if (choice == "5") {
            updateRestaurant();
        } else if (choice == "6") {
            deleteRestaurant();
        } else if (choice == "7") {
            filterRestaurants();
        }
        else if (choice == "0") {
            cout << "Goodbye!\n";
            break;
        } else {
            cout << "Invalid option, try again.\n";
        }
    }
    return 0;
}

 
