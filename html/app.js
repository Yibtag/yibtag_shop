let lisence;

document.addEventListener('keydown', function (event) {
    if (event.key === 'Escape' || event.keyCode === 27) {
        MenuClose();
    }
});

window.addEventListener("message", (event) => {
    if (event.data.type === "open") {
        lisence = event.data.lisence;
        MenuOpen();
        return;
    }

    if (event.data.type === "close") {
        MenuClose();
        return;
    }

    if (event.data.type === "fetch") {
        FetchRecive(event.data.items);
        return;
    }
})


// Menu

const MENU = document.getElementById("menu");

function MenuOpen() {
    MENU.style.visibility = "visible";

    fetch(`https://${GetParentResourceName()}/open`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

function MenuClose() {
    MENU.style.visibility = "hidden";

    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}


// Listings

const CREATE_MENU = document.getElementById("create-menu");
const CREATE_MENU_ITEM = document.getElementById("create-menu-item");
const CREATE_MENU_PRICE = document.getElementById("create-menu-price");
const CREATE_MENU_AMOUNT = document.getElementById("create-menu-amount");

function OpenCreateMenu() {
    CREATE_MENU.style.visibility = "visible";
    MENU.style.visibility = "hidden";
}

function CreateListing() {
    CREATE_MENU.style.visibility = "hidden";
    MENU.style.visibility = "visible";

    fetch(`https://${GetParentResourceName()}/create`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            item: CREATE_MENU_ITEM.value,
            amount: CREATE_MENU_AMOUNT.value,
            price: CREATE_MENU_PRICE.value
        })
    });

    FetchCreate();
}


// Fetching

const ITEMS_LIST = document.getElementById("menu-items");
const SEARCH_INPUT = document.getElementById("topbar-search-input");
const SORTING_INPUT = document.getElementById("topbar-sort-selection");
let current_sidebar_item = 0;

function FetchCreate() {
    fetch(`https://${GetParentResourceName()}/fetch`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

function FetchRecive(items) {
    if (!items) {
        return;
    }

    let json = JSON.parse(JSON.stringify(items));
    ITEMS_LIST.innerHTML = "";

    const sort = SORTING_INPUT.value;

    // Value sorting

    if (sort === "high-value") {
        json = json.slice().sort((a, b) => b.price - a.price);
    } else if (sort === "low-value") {
        json = json.slice().sort((a, b) => a.price - b.price);
    }

    // Date sorting

    if (sort === "newest") {
        json = json.slice().sort((a, b) => b.date - a.date);
    } else if (sort === "oldest") {
        json = json.slice().sort((a, b) => a.date - b.date);
    }

    json.forEach(obj => {
        if (!obj.item.includes(SEARCH_INPUT.value)) {
            return;
        }

        if (current_sidebar_item == 1) {
            if (obj.owner !== lisence) {
                return;
            }

            const date = new Date(obj.date * 1000);
            const element = ITEMS_LIST.innerHTML + `<div class="menu-item"><div class="menu-item-header"><div class="menu-item-date"><ion-icon name="alarm-outline"></ion-icon>${date.customFormat("#DD#/#MM#/#YYYY# - #hh#:#mm#")}</div><div class="menu-item-extra-info"><ion-icon name="information-circle-outline"></ion-icon></div></div><div class="menu-item-image"><img src="/html/inventory_images/${obj.item}.png" alt="${obj.item}"></div><div class="menu-item-info"><div class="menu-item-price">${obj.price}$</div><div class="menu-item-name">${obj.item} (x${obj.amount})</div></div><button class="menu-item-buy" data-id="${obj.id}" onclick="HandleCancel(this)">Cancel</button></div>`;
            
            ITEMS_LIST.innerHTML = element;
        } else {
            const date = new Date(obj.date * 1000);
            const element = ITEMS_LIST.innerHTML + `<div class="menu-item"><div class="menu-item-header"><div class="menu-item-date"><ion-icon name="alarm-outline"></ion-icon>${date.customFormat("#DD#/#MM#/#YYYY# - #hh#:#mm#")}</div><div class="menu-item-extra-info"><ion-icon name="information-circle-outline"></ion-icon></div></div><div class="menu-item-image"><img src="/html/inventory_images/${obj.item}.png" alt="${obj.item}"></div><div class="menu-item-info"><div class="menu-item-price">${obj.price}$</div><div class="menu-item-name">${obj.item} (x${obj.amount})</div></div><button class="menu-item-buy" data-id="${obj.id}" onclick="HandleBuy(this)">Buy</button></div>`;
            
            ITEMS_LIST.innerHTML = element;
        }
    });
}

// Sidebar

const TOPBAR_HEADER = document.getElementById("topbar-header");

function HandleSidebarItem(button) {
    const active_items = document.querySelectorAll(".sidebar-list-item-active");

    active_items.forEach((element) => {
        element.classList.remove("sidebar-list-item-active");
    });
    
    current_sidebar_item = parseInt(button.dataset.listId, 10);

    switch (current_sidebar_item) {
        case 0:
            TOPBAR_HEADER.innerText = "Items";
            break;
        case 1:
            TOPBAR_HEADER.innerText = "Account";
            break;
    }

    FetchCreate();
    button.classList.add("sidebar-list-item-active");
}

// Buy and cancel

function HandleBuy(button) {
    const id = parseInt(button.dataset.id, 10);

    fetch(`https://${GetParentResourceName()}/buy`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            id: id
        })
    });

    FetchCreate();
}

function HandleCancel(button) {
    const id = parseInt(button.dataset.id, 10);

    fetch(`https://${GetParentResourceName()}/cancel`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            id: id
        })
    });

    FetchCreate();
}