// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



contract NFTMarket is ERC721URIStorage,Ownable {
 
  struct NFTListing {
     uint256 tokenId;
     uint256 price;
     address seller;
     bool isForSale;
  }

  address payable admin;
  

  using Counters for Counters.Counter;
  using SafeMath for uint256;
  Counters.Counter private _tokenIDs;
  uint256 totalSupply;

  
   mapping(uint256 => NFTListing) public _listings;
   mapping(uint256 => bool) public isListed;

   mapping(address => uint256[]) private ownedNFT;

   event NFTTransfer(uint256 tokenID, address from, address to, string tokenURI, uint256 price);
  
   mapping(string => string) public getTokenName;
   mapping(string => bool) public getTokenURI;
   constructor() ERC721("Preety's NFTs", "PNFT") {
       admin = payable(msg.sender);
   }
   

   function createNFT(string calldata tokenURI,string calldata nft_name) public  {
      require(getTokenURI[tokenURI]==false, "This token URI can not be listed");
      _tokenIDs.increment();
      uint256 currentID = _tokenIDs.current();
      _safeMint(msg.sender, currentID);
      _setTokenURI(currentID, tokenURI);
      _listings[currentID] = NFTListing(currentID,0,msg.sender,false);
      getTokenURI[tokenURI] = true;
      getTokenName[tokenURI] = nft_name;
   }

  function listNFT(uint256 tokenID, uint256 price) public {
    require(ownerOf(tokenID) == msg.sender, "ownly nft owner can list the nft");
    require(isListed[tokenID]==false, "token can not be listed");
    require(price > 0, "NFT Price must be greater than 0");
    transferFrom(msg.sender, address(this), tokenID);
     NFTListing memory listing = _listings[tokenID];
     listing.isForSale = true;
     listing.price = price;

    totalSupply++;  
    _listings[tokenID] = NFTListing(tokenID, price, msg.sender, true);
    isListed[tokenID] = true;
     ownedNFT[msg.sender].push(tokenID); 
  }

  function purchaseNFT(uint256 tokenID) public payable {
     NFTListing memory listing = _listings[tokenID];
     require(listing.isForSale==true, "NFT not avaialable to sale");
     require(msg.value > 0, "Please pay greater than 0 ehter");
     require(isListed[tokenID]==true, "NFT not available for sale");
     require(listing.price > 0, "NFTMarket: nft not listed for sale");
     require(msg.value >= listing.price, "NFTMarket: incorrect price");
     ERC721(address(this)).transferFrom(address(this), msg.sender, tokenID);
     payable(listing.seller).transfer(listing.price.mul(95).div(100));
     clearListing(tokenID);
     isListed[tokenID] = false;

     
     emit NFTTransfer(tokenID, address(this), msg.sender, "", 0);
  }


   function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
       return IERC721Receiver.onERC721Received.selector;
    }


   function clearListing(uint256 tokenID) private {
     NFTListing memory listing = _listings[tokenID];
     listing.isForSale = false;
     _listings[tokenID].price = 0;
     _listings[tokenID].seller= address(0);
    

    }
 
    function viewAllNFTsForSale() external view returns (NFTListing[] memory) {
       
        NFTListing[] memory result = new NFTListing[](totalSupply);
        
        
        uint256 count = 0;
        
        for (uint256 tokenId = 0; tokenId < totalSupply; tokenId++) {
            if (_listings[tokenId].isForSale) {
                result[count] = _listings[tokenId];
                count++;
            }
        }
        return result;
    }

    // Function to view a user's owned NFTs
    function viewOwnedNFTs(address user) external view returns (uint256[] memory) {
        require(msg.sender == user, "User not authorized");
        uint256[] storage _nftListing = ownedNFT[user];
        require(_nftListing.length > 0, "You are not the owner of nft"); 
        return _nftListing;
        
    }
}





































































