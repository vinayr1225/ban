<script>
  import d3 from 'd3';
  import GraphLegend from './graph/legend.vue';
  import GraphFlag from './graph/flag.vue';
  import GraphDeployment from './graph/deployment.vue';
  import GraphPath from './graph/path.vue';
  import MonitoringMixin from '../mixins/monitoring_mixins';
  import eventHub from '../event_hub';
  import measurements from '../utils/measurements';
  import { timeScaleFormat } from '../utils/date_time_formatters';
  import createTimeSeries from '../utils/multiple_time_series';
  import bp from '../../breakpoints';

  const bisectDate = d3.bisector(d => d.time).left;

  export default {
    props: {
      graphData: {
        type: Object,
        required: true,
      },
      updateAspectRatio: {
        type: Boolean,
        required: true,
      },
      deploymentData: {
        type: Array,
        required: true,
      },
    },

    mixins: [MonitoringMixin],

    data() {
      return {
        baseGraphHeight: 450,
        baseGraphWidth: 600,
        graphHeight: 450,
        graphWidth: 600,
        graphHeightOffset: 120,
        margin: {},
        unitOfDisplay: '',
        yAxisLabel: '',
        legendTitle: '',
        reducedDeploymentData: [],
        measurements: measurements.large,
        currentData: {
          time: new Date(),
          value: 0,
        },
        currentDataIndex: 0,
        currentXCoordinate: 0,
        currentFlagPosition: 0,
        showFlag: false,
        showDeployInfo: true,
        timeSeries: [],
      };
    },

    components: {
      GraphLegend,
      GraphFlag,
      GraphDeployment,
      GraphPath,
    },

    computed: {
      outerViewBox() {
        return `0 0 ${this.baseGraphWidth} ${this.baseGraphHeight}`;
      },

      innerViewBox() {
        if ((this.baseGraphWidth - 150) > 0) {
          return `0 0 ${this.baseGraphWidth - 150} ${this.baseGraphHeight}`;
        }
        return '0 0 0 0';
      },

      axisTransform() {
        return `translate(70, ${this.graphHeight - 100})`;
      },

      paddingBottomRootSvg() {
        return {
          paddingBottom: `${(Math.ceil(this.baseGraphHeight * 100) / this.baseGraphWidth) || 0}%`,
        };
      },
    },

    methods: {
      draw() {
        const breakpointSize = bp.getBreakpointSize();
        const query = this.graphData.queries[0];
        this.margin = measurements.large.margin;
        if (breakpointSize === 'xs' || breakpointSize === 'sm') {
          this.graphHeight = 300;
          this.margin = measurements.small.margin;
          this.measurements = measurements.small;
        }
        this.unitOfDisplay = query.unit || '';
        this.yAxisLabel = this.graphData.y_label || 'Values';
        this.legendTitle = query.label || 'Average';
        this.graphWidth = this.$refs.baseSvg.clientWidth -
                     this.margin.left - this.margin.right;
        this.graphHeight = this.graphHeight - this.margin.top - this.margin.bottom;
        this.baseGraphHeight = this.graphHeight;
        this.baseGraphWidth = this.graphWidth;
        this.renderAxesPaths();
        this.formatDeployments();
      },

      handleMouseOverGraph(e) {
        let point = this.$refs.graphData.createSVGPoint();
        point.x = e.clientX;
        point.y = e.clientY;
        point = point.matrixTransform(this.$refs.graphData.getScreenCTM().inverse());
        point.x = point.x += 7;
        const firstTimeSeries = this.timeSeries[0];
        const timeValueOverlay = firstTimeSeries.timeSeriesScaleX.invert(point.x);
        const overlayIndex = bisectDate(firstTimeSeries.values, timeValueOverlay, 1);
        const d0 = firstTimeSeries.values[overlayIndex - 1];
        const d1 = firstTimeSeries.values[overlayIndex];
        if (d0 === undefined || d1 === undefined) return;
        const evalTime = timeValueOverlay - d0[0] > d1[0] - timeValueOverlay;
        this.currentData = evalTime ? d1 : d0;
        this.currentDataIndex = evalTime ? overlayIndex : (overlayIndex - 1);
        this.currentXCoordinate = Math.floor(firstTimeSeries.timeSeriesScaleX(this.currentData.time));
        const currentDeployXPos = this.mouseOverDeployInfo(point.x);

        if (this.currentXCoordinate > (this.graphWidth - 200)) {
          this.currentFlagPosition = this.currentXCoordinate - 103;
        } else {
          this.currentFlagPosition = this.currentXCoordinate;
        }

        if (currentDeployXPos) {
          this.showFlag = false;
        } else {
          this.showFlag = true;
        }
      },

      renderAxesPaths() {
        this.timeSeries = createTimeSeries(
          this.graphData.queries[0],
          this.graphWidth,
          this.graphHeight,
          this.graphHeightOffset,
        );

        if (this.timeSeries.length > 3) {
          this.baseGraphHeight = this.baseGraphHeight += (this.timeSeries.length - 3) * 20;
        }

        const axisXScale = d3.time.scale()
          .range([0, this.graphWidth - 70]);
        const axisYScale = d3.scale.linear()
          .range([this.graphHeight - this.graphHeightOffset, 0]);

        axisXScale.domain(d3.extent(this.timeSeries[0].values, d => d.time));
        axisYScale.domain([0, d3.max(this.timeSeries[0].values.map(d => d.value))]);

        const xAxis = d3.svg.axis()
          .scale(axisXScale)
          .ticks(d3.time.minute, 60)
          .tickFormat(timeScaleFormat)
          .orient('bottom');

        const yAxis = d3.svg.axis()
          .scale(axisYScale)
          .ticks(measurements.yTicks)
          .orient('left');

        d3.select(this.$refs.baseSvg).select('.x-axis').call(xAxis);

        const width = this.graphWidth;
        d3.select(this.$refs.baseSvg).select('.y-axis').call(yAxis)
          .selectAll('.tick')
          .each(function createTickLines(d, i) {
            if (i > 0) {
              d3.select(this).select('line')
                .attr('x2', width)
                .attr('class', 'axis-tick');
            } // Avoid adding the class to the first tick, to prevent coloring
          }); // This will select all of the ticks once they're rendered
      },
    },

    watch: {
      updateAspectRatio() {
        if (this.updateAspectRatio) {
          this.graphHeight = 450;
          this.graphWidth = 600;
          this.measurements = measurements.large;
          this.draw();
          eventHub.$emit('toggleAspectRatio');
        }
      },
    },

    mounted() {
      this.draw();
    },
  };
</script>

<template>
  <div class="prometheus-graph">
    <h5 class="text-center graph-title">
      {{graphData.title}}
    </h5>
    <div
      class="prometheus-svg-container"
      :style="paddingBottomRootSvg">
      <svg
        :viewBox="outerViewBox"
        ref="baseSvg">
        <g
          class="x-axis"
          :transform="axisTransform">
        </g>
        <g
          class="y-axis"
          transform="translate(70, 20)">
        </g>
        <graph-legend
          :graph-width="graphWidth"
          :graph-height="graphHeight"
          :margin="margin"
          :measurements="measurements"
          :legend-title="legendTitle"
          :y-axis-label="yAxisLabel"
          :time-series="timeSeries"
          :unit-of-display="unitOfDisplay"
          :current-data-index="currentDataIndex"
        />
        <svg
          class="graph-data"
          :viewBox="innerViewBox"
          ref="graphData">
            <graph-path
              v-for="(path, index) in timeSeries"
              :key="index"
              :generated-line-path="path.linePath"
              :generated-area-path="path.areaPath"
              :line-color="path.lineColor"
              :area-color="path.areaColor"
            />
            <graph-deployment
              :show-deploy-info="showDeployInfo"
              :deployment-data="reducedDeploymentData"
              :graph-height="graphHeight"
              :graph-height-offset="graphHeightOffset"
            />
            <graph-flag
              v-if="showFlag"
              :current-x-coordinate="currentXCoordinate"
              :current-data="currentData"
              :current-flag-position="currentFlagPosition"
              :graph-height="graphHeight"
              :graph-height-offset="graphHeightOffset"
            />
            <rect
              class="prometheus-graph-overlay"
              :width="(graphWidth - 70)"
              :height="(graphHeight - 100)"
              transform="translate(-5, 20)"
              ref="graphOverlay"
              @mousemove="handleMouseOverGraph($event)">
            </rect>
        </svg>
      </svg>
    </div>
  </div>
</template>
