//
//  GraphGenerator.swift
//  Deli
//

import Foundation

final class GraphGenerator: Generator {
    
    private typealias GraphInfo = (String, String, String)

    // MARK: - Public

    func generate() throws -> String {
        let output = results
            .flatMap { (result: Results) -> [GraphInfo] in
                let dependencies = result.dependencies
                    .map { (result.instanceType, $0.name, "dependency") }
                let links = result.linkType
                    .map { (result.instanceType, $0, "inheritance") }

                return dependencies + links
            }
            .map { (source, target, type) in
                "    { source: \"\(source)\", target: \"\(target)\", type: \"\(type)\" }"
            }
            .joined(separator: ",\n")

        return """
        <!--
        Directional Force Layout Diagram with node colouring

        Created by d3noob
        Updated May 24, 2017

        http://bl.ocks.org/d3noob/8043434
        -->
        <!DOCTYPE html>
        <meta charset="utf-8">
        <script type="text/javascript" src="http://d3js.org/d3.v3.js"></script>
        <style>
        path.link { fill: none; stroke: #000; opacity: 0.4; stroke-width: 1.5px; }
        path.link.inheritance { stroke-dasharray: 0,2 1; }
        circle { fill: #ccc; stroke: #fff; stroke-width: 1.5px; }
        text { fill: #000; font: 10px sans-serif; pointer-events: none; }
        </style>
        <body>
        <script>
        var links = [
            \(output)
        ]
         
        var nodes = {};
         
        // Compute the distinct nodes from the links.
        links.forEach(function(link) {
            if (nodes[link.source]) {
                nodes[link.source].count ++;
            } else {
                nodes[link.source] = {
                    name: link.source,
                    type: link.type,
                    count: 1
                };
            }

            if (nodes[link.target]) {
                nodes[link.target].count ++;
            } else {
                nodes[link.target] = {
                    name: link.target,
                    type: link.type,
                    count: 1
                };
            }

            link.source = nodes[link.source];
            link.target = nodes[link.target];
        });

        var width = window.innerWidth || 960;
        var height = window.innerHeight || 500;
        var color = d3.scale.category20c();
        var force = d3.layout.force()
            .nodes(d3.values(nodes))
            .links(links)
            .size([width, height])
            .linkDistance(120)
            .charge(-300)
            .on('tick', tick)
            .start();
         
        var svg = d3.select('body').append('svg')
            .attr('width', width)
            .attr('height', height);
         
        // build the arrow.
        svg.append('svg:defs').selectAll('marker')
            .data(['end'])
          .enter().append('svg:marker')
            .attr('id', String)
            .attr('viewBox', '0 -5 10 10')
            .attr('refX', 15)
            .attr('refY', -1.5)
            .attr('markerWidth', 6)
            .attr('markerHeight', 6)
            .attr('orient', 'auto')
          .append('svg:path')
            .attr('d', 'M0,-5L10,0L0,5');
         
        // define the nodes
        var nodebg = svg.selectAll('.nodebg')
            .data(force.nodes())
          .enter().append('g')
            .attr('class', 'nodebg')
            .call(force.drag);

        nodebg.append('circle')
            .attr('r', function (d) { return 7 + d.count; })
            .style('fill', function(d) { return color(d.name); })
            .style('opacity', 0.5);

        // add the links and the arrows
        var path = svg.append('svg:g').selectAll('path')
            .data(force.links())
          .enter().append('svg:path')
            .attr('class', function(d) { return 'link ' + d.type; })
            .attr('marker-end', 'url(#end)');
         
        // define the nodes
        var node = svg
          .selectAll('.node')
            .data(force.nodes())
          .enter().append('g')
            .attr('class', 'node')
            .call(force.drag);

        // add the nodes
        node.append('circle')
            .attr('r', function (d) { return 5; })
            .style('fill', function(d) { return color(d.name); });

        // add the text 
        node.append('text')
            .attr('x', 0)
            .attr('dy', 12)
            .text(function(d) { return d.name; });

        // add the curvy lines
        function tick() {
            path.attr('d', function(d) {
                var dx = d.target.x - d.source.x;
                var dy = d.target.y - d.source.y;
                var dr = Math.sqrt(dx * dx + dy * dy);

                return 'M' + 
                    d.source.x + ',' + 
                    d.source.y + 'A' + 
                    dr + ',' + dr + ' 0 0,1 ' + 
                    d.target.x + ',' + 
                    d.target.y;
            });
         
            nodebg.attr('transform', function(d) { return 'translate(' + d.x + ',' + d.y + ')'; });
            node.attr('transform', function(d) { return 'translate(' + d.x + ',' + d.y + ')'; });
        }
        </script>
        </body>
        </html>
        """
    }

    // MARK: - Private

    private let results: [Results]
    private let properties: [String: Any]

    // MARK: - Lifecycle

    init(results: [Results], properties: [String: Any]) {
        self.results = results
            .filter { !$0.isResolved }
        self.properties = properties
    }
}
