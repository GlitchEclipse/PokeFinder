//
//  Pokemon.swift
//  PokeFinder
//
//  Created by Patrick Polomsky on 4/3/17.
//  Copyright © 2017 Patrick Polomsky. All rights reserved.
//

import Foundation

class Pokemon {
    
    private var _name: String!
    private var _pokedexID: Int!


    var name: String {
        return _name
    }
    
    var pokedexID: Int {
        return _pokedexID
    }



    init(name:String, pokedexId: Int) {
        self._name = name
        self._pokedexID = pokedexId
    }
    
    

}
