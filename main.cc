#include <iostream>
#include <string>
#include <vector>

struct Restaurant {
    std::string name;
    std::string cuisine;
    std::string borough;
};

void showMenu() {
    std::cout << "==============================\n";
    std::cout << "   NYC Restaurant Finder - Prototype   \n";
    std::cout << "==============================\n";
    std::cout << "1) Show sample restaurants\n";
    std::cout << "2) About this project\n";
    std::cout << "0) Exit\n";
    std::cout << "Choose an option: ";
}

void showSampleRestaurants() {
    std::vector<Restaurant> sample = {
        {"Thai Villa", "Thai", "Manhattan"},
        {"Prince Street Pizza", "Italian", "Manhattan"},
        {"Tacos El Bronco", "Mexican", "Brooklyn"}
    };

    std::cout << "\nSample Restaurant Results:\n";
    for (auto &r : sample) {
        std::cout << " - " << r.name
                  << " | " << r.cuisine
                  << " | " << r.borough << "\n";
    }
    std::cout << "\n";
}

void showAbout() {
    std::cout << "\nNYC Restuarant Finder is a restaurant finder app \n"
              << "that integrates NYC health inspections, \n"
              << "Open Restaurants compliance, and 311 complaint data.\n\n";
}

int main() {
    while (true) {
        showMenu();
        std::string choice;
        std::getline(std::cin, choice);

        if (choice == "1") {
            showSampleRestaurants();
        } else if (choice == "2") {
            showAbout();
        } else if (choice == "0") {
            std::cout << "Goodbye!\n";
            break;
        } else {
            std::cout << "Invalid option, try again.\n";
        }
    }
    return 0;
}

 
// Note: This is a simplified prototype version of the NYC Restaurant Finder application for Checkpoint 1.