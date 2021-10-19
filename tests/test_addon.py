#
# SPDX-FileCopyrightText: 2021 Splunk, Inc. <sales@splunk.com>
# SPDX-License-Identifier: LicenseRef-Splunk-1-2020
#
#
import pytest
from splunklib import binding
from pytest_splunk_addon.standard_lib.addon_basic import Basic


class Test_App(Basic):
    def empty_method(self):
        pass

    def test_basic_search(self, splunk_search_util):

        search = '| makeresults | eval src="8.8.8.8"'

        result = splunk_search_util.checkQueryCountIsGreaterThanZero(
            search, interval=20, retries=1
        )

        assert result

    def test_ingested_data(self, record_property, splunk_search_util):
        search = 'search index=main sourcetype="ev:charger"'
        result = splunk_search_util.checkQueryCountIsGreaterThanZero(
            search, interval=20, retries=20
        )

        record_property("dataIngest","present")
        assert result


    def test_synthetic_data(self, record_property, splunk_search_util):
        search = 'search index=main sourcetype="ev:charger:synthetic" InUseCcs=0'
        result = splunk_search_util.checkQueryCountIsGreaterThanZero(
            search, interval=20, retries=20
        )

        record_property("dataIngest","present")
        assert result

    # def test_metric_data(self, splunk_search_util):
    #     search = '| mstats avg(price) AS price WHERE index=em_metrics span=30m'
    #     result = splunk_search_util.checkQueryCountIsGreaterThanZero(
    #         search, interval=20, retries=20
    #     )
    #
    #     #Todo - Check max() value matches expected value (34.9965)
    #
    #     assert result

    # def test_create_engenie_input(self, splunk):
    #
    #     splunk_binding = binding.connect(**splunk)
    #     response = splunk_binding.post(
    #         "engenie_usage",
    #         name="engenie",
    #         index="main",
    #         interval=60
    #     )
    #     assert response == 201



