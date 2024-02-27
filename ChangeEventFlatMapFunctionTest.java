package com.uber.sia.ingest.dsw;

import static org.assertj.core.api.Assertions.assertThat;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.uber.fievel.testing.base.FievelTestBase;
import com.uber.fievel.testing.utils.TestUtils;
import com.uber.sia.common.config.JobConfig;
import com.uber.sia.ingest.models.ChangeEvent;
import com.uber.sia.ingest.service.flink.ChangeEventFlatMapFunction;
import com.uber.sia.ingest.transform.dsw.Explore;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import org.apache.flink.api.common.functions.util.ListCollector;
import org.apache.flink.util.Collector;
import org.junit.Before;
import org.junit.Test;

public class ChangeEventFlatMapFunctionTest extends FievelTestBase {

  private static final ObjectMapper om = new ObjectMapper();

  @Before
  public void init() {
    JobConfig.use(null);
    try {
      JobConfig.from("localzone1", "dev-dsw", "search/ingest/config/local-configs");
    } catch (IOException e) {
      e.printStackTrace();
    } catch (ClassNotFoundException e) {
      e.printStackTrace();
    }
  }

  @Test
  public void testFlatMap() throws Exception {
    ChangeEventFlatMapFunction changeEventFlatMapFunction =
        new ChangeEventFlatMapFunction(
            "hp-dbevents-mysql-phoenix-phoenix-Explore",
            JobConfig.getCachedInstance(),
            0,
            0,
            Collections.emptyMap(),
            Collections.emptyMap());
    Map incoming =
        om.readValue(
            TestUtils.getResourceAsStream(this.getClass(), "dsw/dsw_changeevent.json"), Map.class);
    List<ChangeEvent> changeEventsList = new ArrayList<>();
    Collector<ChangeEvent> collector = new ListCollector<>(changeEventsList);
    changeEventFlatMapFunction.flatMap(incoming, collector);
    assertThat(changeEventsList.size()).isEqualTo(1);
    ChangeEvent changeEvent = changeEventsList.get(0);
    assertThat(changeEvent.id).isEqualTo("c401e35b0d4584d3d33b12afb84527ece13ea0dc");
    assertThat(changeEvent.data).isNotNull();
    assertThat(changeEvent.data).isNotEmpty();
    Map<String, Object> data = changeEvent.data;
    Explore explore = om.convertValue(data, Explore.class);
    assertThat(explore).isNotNull();
    assertThat(explore.getPath())
        .isEqualTo(
            "/localfile/KnowledgeFeeds/gzheng/How_to_train_a_regular_Spark_ML_model_and_save_it_to_Michelangelo.ipynb");
    assertThat(explore.getUser_ldap()).isEqualTo("gzheng");
  }
}
