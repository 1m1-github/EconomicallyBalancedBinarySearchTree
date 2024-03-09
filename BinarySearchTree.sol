// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.18;

/**
 * UNTESTED
 * @title BinarySearchTree: Library for log cost ordering with economic height rebalancing
 * trying to minimizes code length whilst being understand and correct
 * all half precision: 1 bit used to denote leaf node (anything larger than type(uint256).max/2)
 * 0 is the absolute root
 */
library BinarySearchTree {

    struct Node {
        uint value; // also acts as id of the Node
        uint smaller;
        uint larger;
    }

    /**
     * @notice
     * @dev This function is used to find the element in the tree that is larger(?) or equal and closest to value
     * @param nodes is the tree in storage
     * @param nodes_root_id is the root of nodes
     * @param value Value we are looking to locate in the tree
     */
    function find_closest_larger(
        mapping(uint => Node) storage nodes,
        uint nodes_root_id,
        uint value
    ) internal returns (Node memory) {
        Node memory root = nodes[nodes_root_id];

        // found: root.value == value
        // leaf condition: root.value < 0
        if (root.value == value || root.value == type(uint256).max) return root;

        // recursion
        if (value < root.value) return find_closest_larger(nodes, root.smaller, value);
        return find_closest_larger(nodes, root.larger, value);
    }

    /**
     * @notice
     * @dev This function is used to rebalance the tree to have its root be around the median, minimizing height.
     * Economic actors execute this function to save on gas using the pool.
     * @param nodes is the tree in storage
     * @param nodes_root_id is the root of nodes
     */
    function smallest(mapping(uint => Node) storage nodes, uint nodes_root_id) internal returns (uint) {
        Node memory root = nodes[nodes_root_id];

        // leaf condition
        if (root.value == type(uint256).max) return root.value;

        // recursion
        return smallest(nodes, root.smaller);
    }

    /**
     * @notice
     * @dev This function is used to insert a new value into the tree
     * @param nodes is the tree in storage
     * @param nodes_root_id is the root of nodes
     * @param value Value to insert
     */
    function insert(mapping(uint => Node) storage nodes, uint nodes_root_id, uint value) internal returns (uint) {
        Node memory larger = find_closest_larger(nodes, nodes_root_id, value);
        Node memory smaller = nodes[larger.smaller];
        nodes[value] = Node(value, larger.smaller, larger.value);
        larger.smaller = value;
        smaller.larger = value;
    }

    /**
     * @notice
     * @dev This function is used to rebalance the tree to have its root be around the median, minimizing height.
     * Economic actors execute this function to save on gas using the pool.
     * @param nodes is the tree in storage
     * @param nodes_root_id is the root of nodes
     * @param new_nodes is the new tree storage
     * @param new_nodes_root_id is the new root and is checked to be a median
     */
    function rebalance(
        mapping(uint => Node) storage nodes,
        uint nodes_root_id,
        mapping(uint => Node) storage new_nodes,
        uint new_nodes_root_id
    ) external {
        Node memory new_root = find_closest_larger(nodes, nodes_root_id, new_nodes_root_id);
        Node memory nodes_root = nodes[nodes_root_id];

        // check median
        uint num_smaller = count_smaller(nodes, nodes_root_id);
        uint num_larger = count_smaller(nodes, nodes_root_id);
        require(num_larger - num_smaller <= 1);

        // insert root
        new_root.smaller = type(uint).max;
        new_root.larger = type(uint).max;
        new_nodes[0] = new_root;

        // insert smaller of old root
        Node memory current_node = nodes[nodes_root.smaller];
        while (current_node.value != type(uint).max) {
            insert(new_nodes, new_nodes_root_id, current_node.value);
            current_node = nodes[current_node.smaller];
        }

        // insert larger of old root
        current_node = nodes[nodes_root.larger];
        while (current_node.value != type(uint).max) {
            insert(new_nodes, new_nodes_root_id, current_node.value);
            current_node = nodes[current_node.larger];
        }
    }

    /**
     * @notice
     * @dev Count smaller side of tree
     * @param nodes is the tree in storage
     * @param nodes_root_id is the root of nodes
     */
    function count_smaller(mapping(uint => Node) storage nodes, uint nodes_root_id) private returns (uint) {
        Node memory root = nodes[nodes_root_id];
        if (root.value == type(uint).max) return 1;
        return 1 + count_smaller(nodes, root.smaller);
    }

    /**
     * @notice
     * @dev Count larger side of tree
     * @param nodes is the tree in storage
     * @param nodes_root_id is the root of nodes
     */
    function count_larger(mapping(uint => Node) storage nodes, uint nodes_root_id) private returns (uint) {
        Node memory root = nodes[nodes_root_id];
        if (root.value == type(uint).max) return 1;
        return 1 + count_larger(nodes, root.larger);
    }
}
